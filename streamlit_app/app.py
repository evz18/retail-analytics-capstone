import streamlit as st
import pandas as pd  
import joblib 
from pathlib import Path

#A) Configure the webpage 
st.set_page_config(
    page_title = "Olist Customer Satisfaction Predictor",
    page_icon="📦",
    layout="wide"
)

#B) Display title and description
st.title("📦 Olist Customer Satisfaction Predictor")

st.write(
    "Predict the probability of a positive customer review "
    "based on order details and delivery performance"
)

#C) Load the training machine learning pipeline
@st.cache_resource  #prevents reloading model every time change input
def load_model():
    #find folder containing app.py
    model_path = Path(__file__).parent / "olist_satisfaction_model.joblib"
    return joblib.load(model_path)

model = load_model()

st.success("Machine learning model loaded successfully!")

#C2) Store the last prediction between Streamlit reruns.
    # Initially None because no prediction has been made yet.
if "positive_probability" not in st.session_state:
    st.session_state.positive_probability = None

#D) FORMAT TEXT ON THE PAGE
    # Reserve a location near the top of the page
results_container = st.container()

st.subheader('Order Information')

# ---------- ) REMOVED -> three clickable tabs to organize user inputs
# order_tab, delivery_tab, customer_tab = st.tabs([
#     "🛒 Order Details",
#     "🚚 Delivery",
#     "👤 Customer & Purchase"
# ])  #returns 3 object containers where we can place widgets

# E) 3 Columns for page layout 
col1, col2, col3 = st.columns(3)


with col1:
    st.subheader("🛒 Order Details")
        #st.number_input = creates interactive field where user enters input and stored in variable!
        #1) price
    total_price = st.number_input(
        'Order Total (R$)',
        min_value = 0.0,
        max_value = 20000.0,  #derived from .describe()
        value = 100.0
    )   
        #2) items
    num_items = st.number_input(
        'Number of Items',
        min_value = 1,
        max_value = 20,
        value = 1
    )  
        #3) Shipping cost in Brazilian reais
    total_freight = st.number_input(
        "Shipping Cost (R$)",
        min_value=0.0,  
        max_value = 2000.0, 
        value=15.0       # default value shown when app opens
    )

        #4) Product category dropdown
    primary_product_category = st.selectbox(
        "Product Category",
        [
            "bed_bath_table",
            "health_beauty",
            "sports_leisure",
            "computers_accessories",
            "furniture_decor"
        ],
        format_func=lambda x: x.replace("_", " ").title()
    )


with col2:
    st.subheader("🚚 Delivery & Payment")
        #1) delivery days
    delivery_days = st.number_input(
        'Delivery Time (days)',
        min_value = 0,
        max_value = 90,
        value = 7
    )
        #2) Delivery delay = actual delivery date - estimated delivery date
    # Positive = late, negative = early, zero = on time
    delivery_delay = st.number_input(
        "Delivery Delay (Days)",
        min_value = -60,
        max_value = 60,
        value=0,
        help="Positive = late, negative = early"
    )
        #3) Number of payment installments
    payment_installments = st.number_input(
        "Payment Installments",
        min_value=1,
        value=1
    )
            # ) CATEGORICAL USER INPUTS

            # st.selectbox() creates a dropdown menu.
            # The user's selection is stored as a string in the variable.
            #
            # Example:
            # User selects "credit_card"
            # primary_payment_type = "credit_card"
            #
            # The model's preprocessing pipeline will encode this category
            # into the numeric representation needed by the classifier.
        #4) primary payment type
    primary_payment_type = st.selectbox(
        "Payment Method",
        ["credit_card", "boleto", "voucher", "debit_card"],
        format_func = lambda x: x.replace('_', ' ').title()
    )


with col3:
    st.subheader("👤 Customer & Purchase")
    #)Customer location (Brazilian state abbreviations)
    # Dictionary mapping state abbreviations to full names
    state_names = {
        "SP": "São Paulo",
        "RJ": "Rio de Janeiro",
        "MG": "Minas Gerais",
        "RS": "Rio Grande do Sul",
        "PR": "Paraná",
        "SC": "Santa Catarina",
        "BA": "Bahia"
    }

        # 1) Display full names but store abbreviations
    customer_state = st.selectbox(
        "Customer State",
        list(state_names.keys()),
        format_func=lambda x: state_names[x]    #ex) state_name['RJ'] = returns Rio de Jan..
    )
            #) PURCHASE DATE INPUTS

            # range(1, 13) generates integers 1 through 12.
            # list() converts the range into a list for the dropdown.
            # Example: User selects 10 -> purchase_month = 10
        #2) month
    purchase_month = st.selectbox(
        "Purchase Month",
        list(range(1, 13))
    )
            # range(7) generates [0, 1, 2, 3, 4, 5, 6].
            #
            # format_func changes how each option APPEARS to the user!
            # It does NOT change the underlying stored value.
            #
            # Example:
            # User sees "Monday" and selects it.
            # Python stores purchase_dayofweek = 0.
            #
            # This matches pandas .dt.dayofweek:
            # Monday = 0, Sunday = 6.
        #3) purchase day week
    purchase_dayofweek = st.selectbox(
        "Purchase Day of Week",
        #variable should be 0-6 matching the model training
        list(range(7)),
        format_func=lambda x: [
            "Monday", "Tuesday", "Wednesday", "Thursday",
            "Friday", "Saturday", "Sunday"
        ][x]
    )

# ----------------- Make Model Predictions --------

# st.button() returns True when the user clicks the button.
# We only make a prediction when the button is clicked.

if st.button(
    "Predict Customer Satisfaction",
    type="primary",
    use_container_width = True
):
    # Create a DataFrame containing ONE order.
    # Each dictionary key must match a feature name from X_train.
    # Each value comes from the user's Streamlit inputs.
    input_df = pd.DataFrame([{
        "total_price": total_price,
        "total_freight": total_freight,
        "num_items": num_items,
        "payment_installments": payment_installments,
        "delivery_days": delivery_days,
        "delivery_delay": delivery_delay,
        "primary_payment_type": primary_payment_type,
        "primary_product_category": primary_product_category,
        "customer_state": customer_state,
        "purchase_month": purchase_month,
        "purchase_dayofweek": purchase_dayofweek
    }])

    # predict_proba() returns probabilities for each class.
    # For binary classification:
    # Class 0 = negative review, Class 1 = positive review
    #
    # Example output: [[0.25, 0.75]] --> neg review prob, pos review prob
    # [0, 1] selects row 0 (first order), class 1 (pos review probability) -> ex) 0.75
    st.session_state.positive_probability = float(
        model.predict_proba(input_df)[0, 1]
    )
    #Brief notification confirming new prediction was generated
    st.toast(
        "Prediction updated successfully!", icon="✅"
    )


    # ------- DISPLAY PREDICTION RESULTS ----------------------
with results_container:
    
    #Retrieve last saved prediction.
    positive_probability = st.session_state.positive_probability

    
    if positive_probability is not None:
        st.divider()    #horiz separator
        st.subheader("Prediction Results")
        st.caption(
        "Results reflect the last submitted order information. "
        "Click Predict again after changing any inputs."
)

        #  Display the predicted probability as a percentage
        # :.1% formats 0.75 as 75.0%.
        st.metric(
            "Probability of Positive Review",
            f"{st.session_state.positive_probability:.1%}"
        )

        # Visualize progress bar probability on a scale from 0 to 100%
        st.progress(positive_probability)

        # Interpret the prediction using a 50% classification threshold
        if positive_probability >= 0.5:
            st.success("Predicted Outcome: Positive Review")
        else:
            
                st.warning("Predicted Outcome: Negative Review")



# ---------------- MODEL INFORMATION ----------------

# Expander keeps technical details available without cluttering the app.
with st.expander('About the Model'):
    st.write(
        "This application uses a HistGradientBoostingClassifier "
        "trained on historical Olist Brazilian e-commerce orders "
        "to estimate the probability of a positive customer review."
    )

    # Display model evaluation metrics
    st.write("**Model Performance (Held-Out Test Set)**")

    col1, col2, col3 = st.columns(3)
    with col1:
        st.metric("ROC-AUC", "0.706")
    with col2:
        st.metric("Accuracy", "82.3%")
    with col3:
        st.metric("F1 Score", "0.897")

    st.caption(
        "ROC-AUC measures how well the model distinguishes positive "
        "from negative reviews. A score of 0.706 indicates moderate "
        "discrimination. Accuracy should be interpreted alongside "
        "the class distribution and other evaluation metrics."
    )

    st.write("**Limitations**")
    st.write(
        "Predictions are based on historical Brazilian e-commerce data. "
        "Delivery information is required, so predictions apply after "
        "an order has been delivered. Results are estimates of customer "
        "satisfaction, not guarantees."
    )
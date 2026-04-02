# Epidemiology Diabetes Project

## **Project Description**
This study performs a diagnostic analysis of the **Pima Indians Diabetes Database** to identify key physiological predictors of diabetes mellitus. In an epidemiological context, early detection of high-risk factors—such as glucose intolerance and elevated Body Mass Index (BMI)—is critical for preventative healthcare and resource allocation.

### **Key Objectives:**
- **Risk Factor Identification:** Determine the correlation between metabolic markers and disease onset.
- **Data Integrity:** Correct biological impossibilities (e.g., zero-value blood pressure) to ensure statistical validity.
- **Predictive Modeling:** Build a classification tool to assist in clinical screenings for at-risk populations.

  ## Step 1: Data Acquisition & Biological Audit
I imported the Pima Indians Diabetes dataset and conducted a **Biological Reality Check**. 
- **The Issue:** Several clinical variables (Glucose, BMI, Insulin) contained `0` values, which are physiologically impossible. 
- **The Solution:** I performed a comprehensive audit and converted these `0`s into `NA` (Missing Values). 
- **Result:** This revealed significant missingness in the `insulin` (48%) and `triceps` (29%) columns, which must be addressed before modeling to avoid "Zero-Bias" in the risk profiles.

## Step 2: Data Imputation (Handling Missingness)
To preserve the dataset's statistical power (n=768), I implemented **Median Imputation** for the missing clinical values.
- **Why Median?** Clinical markers like Insulin and Glucose often contain outliers. The median provides a more robust central tendency than the mean, ensuring the "imputed" values are representative of the typical patient.
- **Outcome:** Successfully filled 374 missing insulin records and 227 triceps skinfold records, resulting in a complete dataset ready for risk modeling.

  ## Step 3: Feature Standardization & Correlation
To ensure all clinical variables contribute equally to the risk prediction, I applied **Z-score Standardization**. 
- **Variable Scaling:** Normalized features like Insulin and Age to a common scale.
- **Correlation Insight:** I performed a correlation analysis to identify multicollinearity. I found moderate positive correlations between `BMI` (mass) and `Skin Thickness` (triceps), which aligns with expected physiological relationships in metabolic syndrome studies.
- ## Step 4: Predictive Modeling & Results
I developed a **Logistic Regression** model to quantify diabetes risk based on the standardized clinical features.
- **Model Performance:** The classifier achieved an accuracy of approximately **[Insert your accuracy here]%**.
- **Clinical Insight:** By analyzing the model coefficients, `glucose` and `mass` (BMI) were identified as the most statistically significant predictors of disease onset.
- **Conclusion:** This tool demonstrates how automated diagnostic screening can assist clinicians in identifying high-risk individuals before chronic symptoms manifest.

## **Final Results & Clinical Significance**
The Logistic Regression model identified three primary risk factors with high statistical significance ($p < 0.01$):
1.  **Glucose Levels:** The strongest predictor of diabetes onset.
2.  **Body Mass Index (BMI):** A significant positive correlation between obesity and disease risk.
3.  **Pregnancy History:** Statistically significant in this demographic study.

**Insights for Public Health:** While clinical variables like `Insulin` and `Triceps Skinfold` are often measured, this model suggests that for rapid screening, focusing on **Glucose** and **BMI** provides the most predictive "bang for your buck" in resource-limited settings.

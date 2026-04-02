
# Install the library that contains medical datasets
if(!require(mlbench)) install.packages("mlbench")
library(mlbench)
library(tidyverse)

# Load the PimaIndiansDiabetes dataset
data(PimaIndiansDiabetes)
diabetes_data <- PimaIndiansDiabetes

print("Epidemiological Data Loaded!")
head(diabetes_data)
glimpse(diabetes_data)

# 1. Define columns that cannot biologically be zero
clinical_vars <- c("glucose", "pressure", "triceps", "insulin", "mass")

# 2. Audit the zeros across these columns
zero_report <- diabetes_data %>%
  summarise(across(all_of(clinical_vars), ~ sum(.x == 0)))

print("--- Zero Value Audit (Hidden Missing Data) ---")
print(zero_report)

# 3. Convert these impossible zeros to NA (Missing)
diabetes_data_cleaned <- diabetes_data %>%
  mutate(across(all_of(clinical_vars), ~ na_if(.x, 0)))

# 4. Count the actual missingness now
print("--- Actual Missing Values (NAs) ---")
colSums(is.na(diabetes_data_cleaned))

# 1. Fill the missing values (NAs) with the median of each column
diabetes_data_imputed <- diabetes_data_cleaned %>%
  mutate(
    glucose  = ifelse(is.na(glucose),  median(glucose,  na.rm = TRUE), glucose),
    pressure = ifelse(is.na(pressure), median(pressure, na.rm = TRUE), pressure),
    mass     = ifelse(is.na(mass),     median(mass,     na.rm = TRUE), mass),
    triceps  = ifelse(is.na(triceps),  median(triceps,  na.rm = TRUE), triceps),
    insulin  = ifelse(is.na(insulin),  median(insulin,  na.rm = TRUE), insulin)
  )

# 2. Final verification: Everything should be 0 now
print("--- Final Missing Value Check ---")
colSums(is.na(diabetes_data_imputed))

glimpse(diabetes_data_imputed)
ggplot(diabetes_data_imputed, aes(x = diabetes, y = glucose, fill = diabetes)) +
  geom_boxplot() +
  scale_fill_manual(values = c("neg" = "#3498db", "pos" = "#e74c3c")) +
  labs(title = "Glucose Levels by Diabetes Diagnosis",
       subtitle = "Higher median glucose is clearly visible in the positive (pos) group",
       x = "Diabetes Status",
       y = "Plasma Glucose (mg/dL)") +
  theme_minimal()




# 1. Scale all clinical features (Columns 1 through 8)
# We leave the 'diabetes' target (Column 9) as-is
scaled_features <- scale(diabetes_data_imputed[, 1:8])

# 2. Combine the scaled data back with the diabetes labels
final_data <- as.data.frame(cbind(scaled_features, diabetes = diabetes_data_imputed$diabetes))

# 3. Ensure the 'diabetes' column is still a Factor (categorical)
final_data$diabetes <- as.factor(ifelse(final_data$diabetes == 2, "pos", "neg"))

# Check the first few rows - they should all be small numbers now!
head(final_data)

library(corrplot)

# Calculate correlations (excluding the category column)
cor_matrix <- cor(diabetes_data_imputed[, 1:8])

# Plot the matrix
corrplot(cor_matrix, method = "circle", type = "upper", 
         tl.col = "black", title = "Risk Factor Correlation Matrix")


# 1. Split the data (80% Train, 20% Test)
set.seed(123)
train_indices <- sample(1:nrow(final_data), 0.8 * nrow(final_data))
train_set <- final_data[train_indices, ]
test_set  <- final_data[-train_indices, ]

# 2. Train the Logistic Regression Model
# family = "binomial" tells R to perform classification
log_model <- glm(diabetes ~ ., data = train_set, family = "binomial")

# 3. Summarize the Model
summary(log_model)

# 1. Predict on the test set
# Type = "response" gives us probabilities (0 to 1)
probabilities <- predict(log_model, test_set, type = "response")

# 2. Convert probabilities to classes (Threshold = 0.5)
predictions <- ifelse(probabilities > 0.5, "pos", "neg")

# 3. Create the Confusion Matrix
conf_matrix <- table(Predicted = predictions, Actual = test_set$diabetes)
print(conf_matrix)

# 4. Calculate Accuracy
accuracy <- sum(diag(conf_matrix)) / sum(conf_matrix)
print(paste("Model Accuracy:", round(accuracy * 100, 2), "%"))


# 1. Tidy the model results into a data frame
library(broom)
model_results <- tidy(log_model) %>%
  filter(term != "(Intercept)") # Remove the intercept for better scaling

# 2. Create the Coefficient Plot
ggplot(model_results, aes(x = reorder(term, estimate), y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  geom_point(size = 4, color = "#2c3e50") +
  geom_errorbar(aes(ymin = estimate - std.error, ymax = estimate + std.error), width = 0.2) +
  coord_flip() +
  labs(title = "Epidemiological Risk Factors: Model Coefficients",
       subtitle = "Variables to the right of the red line increase diabetes risk",
       x = "Clinical Variable",
       y = "Estimate (Log-Odds Impact)") +
  theme_minimal()
# 1. Create a detailed confusion matrix object
if(!require(caret)) install.packages("caret")
library(caret)

# Convert to factors with the same levels
pred_factor <- factor(predictions, levels = c("neg", "pos"))
actual_factor <- factor(test_set$diabetes, levels = c("neg", "pos"))

# 2. Get the full report
final_report <- confusionMatrix(pred_factor, actual_factor)
print(final_report)

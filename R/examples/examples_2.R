source("R/examples/plot_disparity_decomp.R")

#test code for ordinal


data = data.frame(bmi_cat = NHANES::NHANES$BMI_WHO,
             race = NHANES::NHANES$Race1,
             age = NHANES::NHANES$Age,
             poverty = NHANES::NHANES$Poverty
             )
data = na.omit(data)

out = pb.fit(bmi_cat ~ age + poverty,
             data = data,
             disparity.group = "race",
             majority.group = "White",
             minority.group = c("Black"),
             prop.odds.fail = c("age"),
             family = "ordinal")

print(out)
print(pb_plot_disparity_decomp(out))
saved_path = pb_save_disparity_plot(out, "pb_decomposition_ordinal.png", out_dir = "images")
cat("Saved plot:", saved_path, "\n")
pb_describe_result(out, "Ordinal BMI category model")


#test code for binary outcome


data = data.frame(bmi_bin = as.integer(NHANES::NHANES$BMI > 20) ,
                  race = NHANES::NHANES$Race1,
                  age = NHANES::NHANES$Age,
                  poverty = NHANES::NHANES$Poverty
)
data = na.omit(data)

out = pb.fit(bmi_bin ~ age + poverty,
             data = data,
             disparity.group = "race",
             majority.group = "White",
             minority.group = c("Black"),
             family = "multinomial")

print(out)
print(pb_plot_disparity_decomp(out))
saved_path = pb_save_disparity_plot(out, "pb_decomposition_multinomial.png", out_dir = "images")
cat("Saved plot:", saved_path, "\n")
pb_describe_result(out, "Binary BMI model (multinomial)")

#test code for continuous outcome


data = data.frame(bmi_con = NHANES::NHANES$BMI ,
                  race = NHANES::NHANES$Race1,
                  age = NHANES::NHANES$Age,
                  poverty = NHANES::NHANES$Poverty
)
data = na.omit(data)

out = pb.fit(bmi_con ~ age + poverty,
             data = data,
             disparity.group = "race",
             majority.group = "White",
             minority.group = c("Black"),
             family = "gaussian")

print(out)
print(pb_plot_disparity_decomp(out))
saved_path = pb_save_disparity_plot(out, "pb_decomposition_gaussian.png", out_dir = "images")
cat("Saved plot:", saved_path, "\n")
pb_describe_result(out, "Continuous BMI model (gaussian)")

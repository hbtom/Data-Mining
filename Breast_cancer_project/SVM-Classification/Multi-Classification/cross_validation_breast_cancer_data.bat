rem scale the data_set
svm-scale -l -1 -u 1 breast_cancer_data > breast_cancer_data_scale

rem select the best parameter
python grid.py breast_cancer_data_scale

rem The first parameter cross validation
svm-train -c 8.0 -g 0.5 -v 10 breast_cancer_data_scale

rem The second parameter cross validation
rem svm-train -c -c 2048.0 -g -v 10 0.00195 breast_cancer_data_scale

rem The third parameter coss validation
rem svm-train -c 524288.0 -g 7.62939453125e-6 -v 10 breast_cancer_data_scale


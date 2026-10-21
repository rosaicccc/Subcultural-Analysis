************************************************************
* 漫展文化课题
* 数据来源：问卷调查数据 漫展文化.dta
************************************************************





global controls disposable_income age_group female student capital_city busy interest_years
global mainvars identity event_frequency $controls



************************************************************
* 表2 描述性统计
************************************************************
asdoc sum future_spend_ord identity event_frequency disposable_income age_group female student capital_city busy interest_years if valid_core==1, stat(N mean sd min max) dec(3) replace save("$output/表2_描述性统计.doc")

************************************************************
* 表3 相关系数矩阵与多重共线性检验
************************************************************
asdoc pwcorr future_spend_ord identity event_frequency disposable_income age_group female student capital_city busy interest_years if valid_core==1, sig star(all) dec(3) replace save("$output/表3_相关系数与VIF.doc")

quietly reg future_spend_ord $mainvars if valid_core==1
asdoc vif, dec(3) append save("$output/表3_相关系数与VIF.doc")

************************************************************
* 表4 基准回归：依次加入控制变量
************************************************************
asdoc reg future_spend_ord identity event_frequency if valid_core==1, vce(hc3) nest replace save("$output/表4_基准回归.doc") cnames((1))

asdoc reg future_spend_ord identity event_frequency disposable_income age_group female if valid_core==1, vce(hc3) nest append save("$output/表4_基准回归.doc") cnames((2))

asdoc reg future_spend_ord $mainvars if valid_core==1, vce(hc3) nest append save("$output/表4_基准回归.doc") cnames((3))

************************************************************
* 表5 稳健性检验：三种方法
************************************************************
* (1) 将未来消费档位视为有序变量，改用有序 Logit
asdoc ologit future_spend_ord $mainvars if valid_core==1, vce(robust) nest replace save("$output/表5_稳健性检验.doc") cnames(有序Logit)

* (2) 使用严格有效样本
asdoc reg future_spend_ord $mainvars if valid_very_strict==1, vce(hc3)  nest append save("$output/表5_稳健性检验.doc") cnames(严格样本)

* (3) 剔除 Cook's D 大于 4/N 的强影响观测
quietly reg future_spend_ord $mainvars if valid_core==1
predict double __cook if e(sample), cooksd
scalar __cook_cut=4/e(N)
gen byte __sample_nocook=valid_core==1 & __cook<__cook_cut if !missing(__cook)
asdoc reg future_spend_ord $mainvars if __sample_nocook==1, vce(hc3) nest append save("$output/表5_稳健性检验.doc") cnames(剔除强影响点)
drop __cook __sample_nocook

************************************************************
* 表6 异质性分析：三种分组、六列分组回归
************************************************************
* (1)-(2) 成年人和未成年人
asdoc reg future_spend_ord $mainvars if valid_core==1 & minor==0, vce(hc3) nest replace save("$output/表6_异质性分析.doc") cnames(成年人)
asdoc reg future_spend_ord $mainvars if valid_core==1 & minor==1, vce(hc3) nest append save("$output/表6_异质性分析.doc") cnames(未成年人)

* (3)-(4) 低外部支持和高外部支持
quietly summarize external_support if valid_core==1, detail
scalar __med_external=r(p50)
gen byte __high_external=external_support>__med_external if valid_core==1 & !missing(external_support)
asdoc reg future_spend_ord $mainvars if valid_core==1 & __high_external==0,vce(hc3) nest append save("$output/表6_异质性分析.doc") cnames(低外部支持)
asdoc reg future_spend_ord $mainvars if valid_core==1 & __high_external==1,vce(hc3) nest append save("$output/表6_异质性分析.doc") cnames(高外部支持)

* (5)-(6) 兴趣年限较短和较长
quietly summarize interest_years if valid_core==1, detail
scalar __med_interest=r(p50)
gen byte __high_interest=interest_years>__med_interest if valid_core==1 & !missing(interest_years)
asdoc reg future_spend_ord $mainvars if valid_core==1 & __high_interest==0,vce(hc3) nest append save("$output/表6_异质性分析.doc") cnames(兴趣年限较短)
asdoc reg future_spend_ord $mainvars if valid_core==1 & __high_interest==1,vce(hc3) nest append save("$output/表6_异质性分析.doc") cnames(兴趣年限较长)
drop __high_external __high_interest

************************************************************
* 表7 机制路径检验：只检验 X -> M，统一加入全部控制变量
************************************************************
asdoc reg consumer_impulsivity $mainvars if valid_core==1, vce(hc3) nest replace save("$output/表7_机制路径检验.doc") cnames(消费冲动)

asdoc reg behavior_intention $mainvars if valid_core==1, vce(hc3) nest append save("$output/表7_机制路径检验.doc") cnames(行为意向)



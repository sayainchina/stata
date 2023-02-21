clear

*去掉2017年以前的数据
drop if year <= 2020

*去掉不存在的国家与地区
drop if country_exists_o == 0
drop if country_exists_d == 0

*去掉无用数据
drop country_id_o country_id_d country_exists_o country_exists_d gmt_offset_2020_o gmt_offset_2020_d distw_harmonic distw_arithmetic distw_harmonic_jh distw_arithmetic_jh main_city_source_o main_city_source_d distcap diplo_disagreement scaled_sci_2021 comlang_ethno legal_old_o legal_old_d legal_new_o legal_new_d comleg_pretrans comleg_posttrans transition_legalchange comrelig heg_o heg_d col_dep_end_year col_dep_end_conflict empire sibling_ever sibling sever_year sib_conflict pop_o pop_d gdp_o gdp_d gdpcap_o gdpcap_d pop_source_o pop_source_d gdp_source_o gdp_source_d gdp_ppp_o gdp_ppp_d gdpcap_ppp_o gdpcap_ppp_d pop_pwt_o pop_pwt_d gdp_ppp_pwt_o gdp_ppp_pwt_d gatt_o gatt_d eu_o eu_d rta_coverage entry_cost_o entry_cost_d entry_proc_o entry_proc_d entry_time_o entry_time_d entry_tp_o entry_tp_d tradeflow_comtrade_o tradeflow_comtrade_d tradeflow_baci manuf_tradeflow_baci tradeflow_imf_o tradeflow_imf_d 



*导入农业贸易合并数据
import delimited "E:\研究生\毕业论文\论文原始数据\合并农业贸易数据.csv"
save "E:\研究生\毕业论文\论文原始数据\合并农业贸易数据.dta",replace
 

*使用农业贸易数据作为基底，进行合并
merge m:1 year reportercode partnercode using "E:\研究生\毕业论文\论文原始数据\rta.dta"

*提取前4位年份数据
gen yearnew=substr(period,1,4)

*将年和月改为数值型，并替换之前变量
destring year month, replace

*将年和月改为字符型，并替换之前变量
tostring year month,replace


*安装查重包
ssc install unique

*查重
unique partnercode landlock

*报告重复有哪些，完整列出（大数据不好使）
duplicates list partnercode landlock

*报告重复有哪些，仅显示重复的数据是什么
duplicates examples

*利用bysort进行分组查看，egen创建一个count的组，并计算partnercode出现了几次

bysort partnercode landlock : egen count = count(partnercode)
bro if count >=2

*暴力删除
duplicates drop partnercode landlock , force //单纯的重复

*bysort先排序，然后egen创建新表，mean平均数据
bysort yearmonth : egen average = mean(stringencyindex_average)


*按照2017年新增2018年数据
expand 2 if year==2017,gen(d1)
replace year=2018 if d1==1

*替换命令
replace confirmedcases = 0 if confirmedcases == .


*删除相同代码，不同数字的国家
replace iso3num_o = 842 if iso3num_o == 840
replace iso3num_d = 842 if iso3num_d == 840
replace iso3num_o = 251 if iso3num_o == 250
replace iso3num_d = 251 if iso3num_d == 250
replace iso3num_d = 699 if iso3num_d == 356
replace iso3num_o = 699 if iso3num_o == 356
replace iso3num_d = 579 if iso3num_d == 578
replace iso3num_o = 579 if iso3num_o == 578
replace iso3num_o = 757 if iso3num_o == 756
replace iso3num_d = 757 if iso3num_d == 756

*变更年月为字符串并生成新变量“yearmonth”
tostring year month,replace
replace month = "01" if month == "1"
replace month = "02" if month == "2"
replace month = "03" if month == "3"
replace month = "04" if month == "4"
replace month = "05" if month == "5"
replace month = "06" if month == "6"
replace month = "07" if month == "7"
replace month = "08" if month == "8"
replace month = "09" if month == "9"
generate str yearmonth = year + month

*合并AB数据库
rename iso3_o iso3_o1
rename iso3_d iso3_o
rename iso3_o1 iso3_d
rename iso3num_d iso3num_d1
rename iso3num_o iso3num_d
rename iso3num_d1 iso3num_o
drop dist contig comlang comcol col45 colony curcol wto rta rta_type average_o average_d confirmedcases_o confirmeddeaths_o confirmedcases_d confirmeddeaths_d smctry landlock 
use "G:\研究生\毕业论文\中间过程数据\第二阶段\20230214 双边数据合并数据库\数据A.dta", clear
rename iso3_o iso3_o1
rename iso3_d iso3_o
rename iso3_o1 iso3_d
rename iso3num_d iso3num_d1
rename iso3num_o iso3num_d
rename iso3num_d1 iso3num_o
drop dist contig comlang comcol col45 colony curcol wto rta rta_type average_o average_d confirmedcases_o confirmeddeaths_o confirmedcases_d confirmeddeaths_d smctry landlock 
rename sumprimaryvalue_o sumprimaryvalue_d
save "G:\研究生\毕业论文\中间过程数据\第二阶段\20230214 双边数据合并数据库\数据B.dta"
use "G:\研究生\毕业论文\中间过程数据\第二阶段\20230214 双边数据合并数据库\数据A.dta", clear
use "G:\研究生\毕业论文\中间过程数据\第二阶段\20230214 双边数据合并数据库\数据B.dta", clear
use "G:\研究生\毕业论文\中间过程数据\第二阶段\20230214 双边数据合并数据库\数据A.dta", clear
merge 1:1 yearmonth year month iso3num_o iso3_o flowcode iso3num_d iso3_d using "G:\研究生\毕业论文\中间过程数据\第二阶段\20230214 双边数据合并数据库\数据B.dta"

*不显示科学计数法
format yearmonth %20.0f

*创建组，然后组成面板
gen pair=_n
xtset pair yearmonth , monthly
xtdes

*取对数处理
gen lndist= ln(dist)
gen lnex_fob= ln(1+sumprimaryvalue_o)
gen lnim_cif= ln(1+sumprimaryvalue_d)
gen lnsi_i= ln(1+stringencyindex_o)
gen lnsi_j= ln(1+stringencyindex_d)
gen lnconfirmeddeaths_o= ln(1+confirmeddeaths_o)
gen lnconfirmeddeaths_d= ln(1+confirmeddeaths_d)
gen lnconfirmedcases_o= ln(1+confirmedcases_o)
gen lnconfirmedcases_d= ln(1+confirmedcases_d)

drop sumprimaryvalue_o sumprimaryvalue_d dist average_o average_d 
order pair yearmonth iso3_o iso3num_o iso3_d iso3num_d lnim_cif lnex_fob lndist contig comlang comcol col45 colony curcol wto rta lnsi_i lnsi_j rta_type confirmedcases_o confirmedcases_d confirmeddeaths_o confirmeddeaths_d smctry landlock



*处理部分数据（将不存在数据设置为0）
replace comlang = 0 if comlang == .
replace comcol = 0 if comcol == .
replace col45 = 0 if col45 == .
replace confirmedcases_o = 0 if confirmedcases_o == .
replace confirmedcases_d = 0 if confirmedcases_d == .
replace confirmeddeaths_o = 0 if confirmeddeaths_o == .
replace confirmeddeaths_d = 0 if confirmeddeaths_d == .

replace confirmedcases_o = confirmedcases_o + 1
replace confirmedcases_d = confirmedcases_d + 1


*回归？
xtreg lnex_fob confirmeddeaths_o confirmeddeaths_d confirmedcases_o confirmedcases_d lndist contig comlang col45 smctry landlock wto rta lnsi_i lnsi_j
reg lnex_fob confirmeddeaths_o confirmeddeaths_d confirmedcases_o confirmedcases_d lndist contig comlang col45 smctry landlock wto rta lnsi_i lnsi_j
replace confirmeddeaths_o = confirmeddeaths_o + 1
replace confirmeddeaths_d = confirmeddeaths_d + 1

replace average_o = 0 if average_o == .
replace average_d = 0 if average_d == .


*去掉不存在国家与地区
drop if iso3num_d == 0
drop if iso3num_d == 10
drop if iso3num_d == 16
drop if iso3num_d == 28
drop if iso3num_d == 51
drop if iso3num_d == 74
drop if iso3num_d == 86
drop if iso3num_d == 92
drop if iso3num_d == 136
drop if iso3num_d == 162
drop if iso3num_d == 166
drop if iso3num_d == 175
drop if iso3num_d == 184
drop if iso3num_d == 200
drop if iso3num_d == 226
drop if iso3num_d == 230
drop if iso3num_d == 238
drop if iso3num_d == 239
drop if iso3num_d == 254
drop if iso3num_d == 258
drop if iso3num_d == 260
drop if iso3num_d == 278
drop if iso3num_d == 280
drop if iso3num_d == 292
drop if iso3num_d == 312
drop if iso3num_d == 334
drop if iso3num_d == 336
drop if iso3num_d == 360
drop if iso3num_d == 408
drop if iso3num_d == 458
drop if iso3num_d == 462
drop if iso3num_d == 473
drop if iso3num_d == 474
drop if iso3num_d == 490
drop if iso3num_d == 499
drop if iso3num_d == 500
drop if iso3num_d == 520
drop if iso3num_d == 527
drop if iso3num_d == 530
drop if iso3num_d == 530
drop if iso3num_d == 531
drop if iso3num_d == 532
drop if iso3num_d == 534
drop if iso3num_d == 535
drop if iso3num_d == 540
drop if iso3num_d == 568
drop if iso3num_d == 570
drop if iso3num_d == 574
drop if iso3num_d == 577
drop if iso3num_d == 580
drop if iso3num_d == 581
drop if iso3num_d == 583
drop if iso3num_d == 584
drop if iso3num_d == 585
drop if iso3num_d == 586
drop if iso3num_d == 612
drop if iso3num_d == 624
drop if iso3num_d == 637
drop if iso3num_d == 638
drop if iso3num_d == 652
drop if iso3num_d == 654
drop if iso3num_d == 659
drop if iso3num_d == 660
drop if iso3num_d == 662
drop if iso3num_d == 666
drop if iso3num_d == 670
drop if iso3num_d == 678
drop if iso3num_d == 704
drop if iso3num_d == 720
drop if iso3num_d == 732
drop if iso3num_d == 736
drop if iso3num_d == 772
drop if iso3num_d == 796
drop if iso3num_d == 798
drop if iso3num_d == 807
drop if iso3num_d == 810
drop if iso3num_d == 837
drop if iso3num_d == 838
drop if iso3num_d == 839
drop if iso3num_d == 876
drop if iso3num_d == 882
drop if iso3num_d == 886
drop if iso3num_d == 890
drop if iso3num_d == 891
drop if iso3num_d == 899
drop if iso3num_d == 316
drop if iso3num_d == 438
drop if iso3num_d == 492


drop if iso3num_o == 0
drop if iso3num_o == 10
drop if iso3num_o == 16
drop if iso3num_o == 28
drop if iso3num_o == 51
drop if iso3num_o == 74
drop if iso3num_o == 86
drop if iso3num_o == 92
drop if iso3num_o == 136
drop if iso3num_o == 162
drop if iso3num_o == 166
drop if iso3num_o == 175
drop if iso3num_o == 184
drop if iso3num_o == 200
drop if iso3num_o == 226
drop if iso3num_o == 230
drop if iso3num_o == 238
drop if iso3num_o == 239
drop if iso3num_o == 254
drop if iso3num_o == 258
drop if iso3num_o == 260
drop if iso3num_o == 278
drop if iso3num_o == 280
drop if iso3num_o == 292
drop if iso3num_o == 312
drop if iso3num_o == 334
drop if iso3num_o == 336
drop if iso3num_o == 360
drop if iso3num_o == 408
drop if iso3num_o == 458
drop if iso3num_o == 462
drop if iso3num_o == 473
drop if iso3num_o == 474
drop if iso3num_o == 490
drop if iso3num_o == 499
drop if iso3num_o == 500
drop if iso3num_o == 520
drop if iso3num_o == 527
drop if iso3num_o == 530
drop if iso3num_o == 530
drop if iso3num_o == 531
drop if iso3num_o == 532
drop if iso3num_o == 534
drop if iso3num_o == 535
drop if iso3num_o == 540
drop if iso3num_o == 568
drop if iso3num_o == 570
drop if iso3num_o == 574
drop if iso3num_o == 577
drop if iso3num_o == 580
drop if iso3num_o == 581
drop if iso3num_o == 583
drop if iso3num_o == 584
drop if iso3num_o == 585
drop if iso3num_o == 586
drop if iso3num_o == 612
drop if iso3num_o == 624
drop if iso3num_o == 637
drop if iso3num_o == 638
drop if iso3num_o == 652
drop if iso3num_o == 654
drop if iso3num_o == 659
drop if iso3num_o == 660
drop if iso3num_o == 662
drop if iso3num_o == 666
drop if iso3num_o == 670
drop if iso3num_o == 678
drop if iso3num_o == 704
drop if iso3num_o == 720
drop if iso3num_o == 732
drop if iso3num_o == 736
drop if iso3num_o == 772
drop if iso3num_o == 796
drop if iso3num_o == 798
drop if iso3num_o == 807
drop if iso3num_o == 810
drop if iso3num_o == 837
drop if iso3num_o == 838
drop if iso3num_o == 839
drop if iso3num_o == 876
drop if iso3num_o == 882
drop if iso3num_o == 886
drop if iso3num_o == 890
drop if iso3num_o == 891
drop if iso3num_o == 899
drop if iso3num_o == 316
drop if iso3num_o == 438
drop if iso3num_o == 492

*双缩尾处理，去掉1%和99%数据
winsor2 sumprimaryvalue_o sumprimaryvalue_d confirmeddeaths_o confirmeddeaths_d, cut(1 99)


*输出命令
estfe m1 m2 m3 m4, labels(pair_o "出口方固定效应" pair_d "进口方固定效应" pair "出口方——进口方固定效应" yearmonth "时间固定效应")

est store m1

esttab m1 m2 m3 m4 using L:\研究生\毕业论文\输出数据\机制性检验.rtf , replace b(%12.3f) se(%12.3f) nogap compress ///  
  s(N r2) star(* 0.1 ** 0.05 *** 0.01) ///
  indicate(`r(indicate_fe)')

  
  
  *  indicate("出口方固定效应=*pair_o*" "进口方固定效应=*pair_d*" "出口方——进口方固定效应=*pair*" "时间固定效应=*yearmonth*")
  
  
  reghdfe , absorb(id year)
  
  
  进口国疫情防控政策取对数
  
  出口国疫情防控政策取对数
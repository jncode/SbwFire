#!/bin/bash

##
## Analyses_Dec06_v2.0.sh
## March 12th, 2007
##      Analysis #1 is good, keep this version
##
# ## Analyses_Dec06_v3.0.sh
## March 12th, 2007
##      Added Analysis #2 and #3
##
# ## Analyses_Dec06_v3.1.sh
## Nov-Dec, 2011
##      Modifications for manuscript in CJFR
##
##

g.gisenv set=GISDBASE=/home/jn/Canada/Data/grassdata
g.gisenv set=LOCATION_NAME=ontario
g.gisenv set=MAPSET=FireSBW

# Extract a chunk of Analyses_Dec06_v2.0.sh from $1 to $2
# and save in $3
ExtractFile() {
if [ -f "$3" ]; then rm "$3"; fi
touch "$3"
trig=0

IFS_bck="$IFS"
IFS=""

while read line
do
if [[ $line == "$1" ]]
then
        trig=1
        echo $trig
fi
if [[ $line == "$2" ]]
then
        break
fi
if [[ "$trig" == 2 ]]
then 
        echo $line | sed "s/\#//" | sed "s/^ //" >> "$3"
fi
if [[ "$trig" == 1 ]]
then 
        trig=2
fi
done < Analyses_Dec06_v3.0.sh

IFS="$IFS_bck"
}

##########################################
# Sbw coverages from 1941 to 2005
##########################################
OverlaySbw() {
# Start by overlaying the first 2 years
        g.remove vect=a
        g.remove vect=b
        g.remove vect=c
        g.copy vect=sbw1941mod2sev@sbw,a
        echo "ALTER TABLE a DROP COLUMN area"|db.execute
        echo "ALTER TABLE a DROP COLUMN perimeter"|db.execute
        echo "ALTER TABLE a DROP COLUMN SBW41_"|db.execute
        echo "ALTER TABLE a RENAME COLUMN SBW41_id TO SBW1941"|db.execute

        g.copy vect=sbw1942mod2sev@sbw,b
        echo "ALTER TABLE b DROP COLUMN area"|db.execute
        echo "ALTER TABLE b DROP COLUMN perimeter"|db.execute
        echo "ALTER TABLE b DROP COLUMN SBW42_"|db.execute
        echo "ALTER TABLE b RENAME COLUMN SBW42_id TO SBW1942"|db.execute

        v.overlay ainput=a atype=area binput=b btype=area output=c operator=or
        echo "ALTER TABLE c DROP COLUMN a_cat"|db.execute
        echo "ALTER TABLE c DROP COLUMN b_cat"|db.execute
        echo "ALTER TABLE c RENAME COLUMN a_SBW1941 TO SBW1941"|db.execute
        echo "ALTER TABLE c RENAME COLUMN b_SBW1942 TO SBW1942"|db.execute

# overlay from 1943 to 1964
        for ((year=1943 ; year<=1964 ; year++))
        do
#                String operations to extract endyear (last 2 digits of the year)
                endyear=${year:2:4}

#                Test for the presence of sbw record for that year
                if [ -f "/home/jn/Canada/Data/grassdata/ontario/sbw/dbf/sbw"$year"mod2sev.dbf" ]
                then
                    g.remove vect=a
                    g.remove vect=b
                    g.copy vect=c,a
                    g.remove vect=c
                    g.copy vect=sbw"$year"mod2sev@sbw,b
                    echo "ALTER TABLE b DROP COLUMN area"|db.execute
                    echo "ALTER TABLE b DROP COLUMN perimeter"|db.execute
                    echo "ALTER TABLE b DROP COLUMN SBW"$endyear"_"|db.execute
                    echo "ALTER TABLE b RENAME COLUMN SBW"$endyear"_id TO SBW"$year""|db.execute
                    v.overlay ainput=a atype=area binput=b btype=area output=c operator=or
                    echo "ALTER TABLE c DROP COLUMN a_cat"|db.execute
                    echo "ALTER TABLE c DROP COLUMN b_cat"|db.execute
                    for ((year2=1941 ; year2<year ; year2++))
                    do
                            if [ -f "/home/jn/Canada/Data/grassdata/ontario/sbw/dbf/sbw"$year2"mod2sev.dbf" ]
                            then
                                    echo "ALTER TABLE c RENAME COLUMN a_sbw"$year2" TO SBW"$year2""|db.execute
                            fi
                    done
                    echo "ALTER TABLE c RENAME COLUMN b_sbw"$year" TO SBW"$year""|db.execute
                else
                        echo "ALTER TABLE c ADD COLUMN sbw"$year" INT"|db.execute
                fi
        done

# Add sbw6598
    g.remove vect=a
    g.remove vect=b
    g.copy vect=c,a
    g.remove vect=c
    v.overlay ainput=a atype=area binput=sbw6598@sbw btype=area output=c operator=or

    echo "ALTER TABLE c DROP COLUMN b_cat"|db.execute
    echo "ALTER TABLE c DROP COLUMN b_area"|db.execute
    echo "ALTER TABLE c DROP COLUMN b_perimeter"|db.execute
    echo "ALTER TABLE c DROP COLUMN b_sbw6598_"|db.execute
    echo "ALTER TABLE c DROP COLUMN b_sbw6598_id"|db.execute
    echo "ALTER TABLE c DROP COLUMN b_ontario_"|db.execute
    echo "ALTER TABLE c DROP COLUMN b_ontario_id"|db.execute
    echo "ALTER TABLE c DROP COLUMN b_sbw"|db.execute
    echo "ALTER TABLE c DROP COLUMN b_freq"|db.execute
    echo "ALTER TABLE c DROP COLUMN a_cat"|db.execute
    for ((year=1941 ; year <=1964 ; year++))
    do
        echo "ALTER TABLE c RENAME COLUMN a_sbw"$year" TO SBW"$year""|db.execute
    done
    for ((year=1965 ; year <=1998 ; year++))
    do
        endyear=${year:2:4}
        echo "ALTER TABLE c RENAME COLUMN b_a"$endyear"_id TO SBW"$year""|db.execute
    done

# overlay from 1999 to 2005
    for ((year=1999 ; year<=2005 ; year++))
    do
#        String operations to extract endyear (last 2 digits of the year)
        endyear=${year:2:4}

#        Test for the presence of sbw record for that year
        if [ -f "/home/jn/Canada/Data/grassdata/ontario/sbw/dbf/sbw"$year"mod2sev.dbf" ]
        then
            g.remove vect=a
            g.remove vect=b
            g.copy vect=c,a
            g.remove vect=c
            g.copy vect=sbw"$year"mod2sev@sbw,b
            echo "ALTER TABLE b DROP COLUMN area"|db.execute
            echo "ALTER TABLE b DROP COLUMN perimeter"|db.execute
            echo "ALTER TABLE b DROP COLUMN SBW"$endyear"_"|db.execute
            echo "ALTER TABLE b RENAME COLUMN SBW"$endyear"_id TO SBW"$year""|db.execute
            v.overlay ainput=a atype=area binput=b btype=area output=c operator=or
            echo "ALTER TABLE c DROP COLUMN a_cat"|db.execute
            echo "ALTER TABLE c DROP COLUMN b_cat"|db.execute
            for ((year2=1941 ; year2<year ; year2++))
            do
                echo "ALTER TABLE c RENAME COLUMN a_sbw"$year2" TO SBW"$year2""|db.execute
            done
                echo "ALTER TABLE c RENAME COLUMN b_sbw"$year" TO SBW"$year""|db.execute
        else
            echo "ALTER TABLE c ADD COLUMN sbw"$year" INT"|db.execute
        fi
    done

    for ((year=1941 ; year<=2005 ; year++))
    do
        echo $year
        echo "UPDATE c SET sbw"$year" = 0 WHERE sbw"$year" IS NULL"|db.execute
        echo "UPDATE c SET sbw"$year" = 1 WHERE sbw"$year" > 0"|db.execute
    done

    g.remove vect=sbw4105
    g.copy vect=c,sbw4105
    g.remove vect=a
    g.remove vect=b
    g.remove vect=c
}

PlotAnnualDef() {
        g.remove vect=sbw4105_analysis
        g.copy vect=sbw4105,sbw4105_analysis
        echo "ALTER TABLE sbw4105_analysis ADD COLUMN area double precision"|db.execute
        v.to.db map=sbw4105_analysis option=area col=area unit=h
        num=`v.info -c sbw4105_analysis|wc -l`
        rm sbw4105.txt sbw4105.R
        touch sbw4105.txt
        for ((i = 1941; i <= 2005; i++))
        do
            echo "$i `echo "select * from sbw4105_analysis where sbw"$i" > 0"|db.select|cut -d"|" -f"$num"| awk '$1 > 0 { sum = sum + $1} END {print sum}'`" >> sbw4105.txt
        done
        echo 'sbw4105 <- read.table(file="sbw4105.txt")' >> sbw4105.R
        echo 'sbw4105.ts <- ts(sbw4105[,2],start=1941,end=2005)' >> sbw4105.R
        echo 'pdf(file="sbw4105.pdf")' >> sbw4105.R
        echo 'plot(sbw4105.ts,xlab="Year",ylab="Area (ha)",main="Area defoliated by SBW in Ontario")' >> sbw4105.R
        echo 'dev.off()' >> sbw4105.R
        R --no-save --no-restore < sbw4105.R
        acroread sbw4105.pdf &
        g.remove vect=sbw4105_analysis
        rm sbw4105.txt sbw4105.R sbw4105.pdf        
}

AddDefzone() {
        g.remove vect=a
        g.remove vect=b
        g.remove vect=c
        g.remove vect=sbw4105_old
        g.copy vect=sbw4105,sbw4105_old
        g.copy vect=sbw4105,a
        g.remove vect=sbw4105
        g.copy vect=defzone@sbw,b
        echo "ALTER TABLE b DROP COLUMN area"|db.execute
        echo "ALTER TABLE b DROP COLUMN perimeter"|db.execute
        echo "ALTER TABLE b DROP COLUMN valueid"|db.execute
        echo "ALTER TABLE b DROP COLUMN polyid"|db.execute
        echo "ALTER TABLE b DROP COLUMN defzone_"|db.execute
        echo "ALTER TABLE b RENAME COLUMN defzone_id TO defzone"|db.execute
        v.overlay ainput=a atype=area binput=b btype=area output=sbw4105 operator=and

        for ((b=1941 ; b<=2005 ; b++))
        do
            echo "ALTER TABLE sbw4105 RENAME COLUMN a_sbw"$b" TO SBW"$b""|db.execute
        done

        echo "ALTER TABLE sbw4105 DROP COLUMN a_cat"|db.execute
        echo "ALTER TABLE sbw4105 DROP COLUMN b_cat"|db.execute
        echo "ALTER TABLE sbw4105 RENAME COLUMN b_defzone TO defzone"|db.execute
        g.remove vect=a,b,sbw4105_old
}

BuildSbwBelt() {
        g.remove vect=b
        g.remove vect=sbw4105x
        g.copy vect=sbw4105,sbw4105x
        echo "ALTER TABLE sbw4105x ADD COLUMN newcat integer"|db.execute
        echo "UPDATE sbw4105x SET newcat=1"|db.execute
        v.reclass input=sbw4105x output=b column=newcat
        v.dissolve input=b output=sbwbelt
        g.remove vect=sbw4105x,b
}

BuildFreqDef() {
        g.remove vect=sbw4105_freq
        g.copy vect=sbw4105,sbw4105_freq 

        echo "ALTER TABLE sbw4105_freq ADD COLUMN freqdef integer"|db.execute

        sqlcom="UPDATE sbw4105_freq SET freqdef="
        for ((year=1941 ; year<=2005 ; year++))
        do
            sqlcom=$sqlcom"sbw"$year"+"
        done
        sqlcom=`echo $sqlcom|sed 's/+$//'`
        echo $sqlcom|db.execute

        for ((year=1941 ; year<=2005 ; year++))
        do
            echo "ALTER TABLE sbw4105_freq DROP COLUMN sbw"$year""|db.execute
        done
}

FreqDefByZone() {
    rm area_defoliated_1941_2005_byzone.txt
    g.remove vect=sbw4105_freq_byzone
    g.copy vect=sbw4105,sbw4105_freq_byzone
    echo "ALTER TABLE sbw4105_freq_byzone ADD COLUMN area double precision"|db.execute
    v.to.db map=sbw4105_freq_byzone option=area col=area unit=h
    num=`v.info -c sbw4105_freq_byzone|wc -l`
    for ((i = 1941; i <= 2005; i++))
    do
        echo "$i `echo "select * from sbw4105_freq_byzone where sbw"$i" > 0 and defzone = 3"|db.select|cut -d"|" -f"$num"| awk '$1 > 0 { sum = sum + $1} END {print sum}'` `echo "select * from sbw4105_freq_byzone where sbw"$i" > 0 and defzone = 4"|db.select|cut -d"|" -f"$num"| awk '$1 > 0 { sum = sum + $1} END {print sum}'` `echo "select * from sbw4105_freq_byzone where sbw"$i" > 0 and defzone = 5"|db.select|cut -d"|" -f"$num"| awk '$1 > 0 { sum = sum + $1} END {print sum}'`" >> area_defoliated_1941_2005_byzone.txt
    done
}


###########################################
# Fire coverages from 1921 to 2005
###########################################
OverlayFire() {
        for ((year=1941 ; year<=2005 ; year++))
        do
                echo $year
                g.remove vect=a,b
                if [ -f "/home/jn/Canada/Data/grassdata/ontario/fire/dbf/fire"$year".dbf" ]        
                then        
#                        Remove several columns useless for the analysis and add one column year_id filled with "1"
                        g.copy vect=fire"$year"@fire,a
                        num=`db.describe -c a|wc -l`
                        let "num=$num-1"
                        sqlcom="ALTER TABLE a "
                        for ((x=2 ; x<=num ; x++))
                        do
                                colname=`echo "select * from a"|db.select|head -1|cut -d"|" -f$x`
                                sqlcom=$sqlcom" DROP COLUMN "$colname","
                        done
                        sqlcom=`echo $sqlcom|sed 's/,$/;/'`
                        echo $sqlcom|db.execute
                        echo "ALTER TABLE a ADD COLUMN fire"$year" integer"|db.execute
                        echo "UPDATE a SET fire"$year" = 1"|db.execute
                        if [ -d /home/jn/Canada/Data/grassdata/ontario/FireSBW/vector/fire"$year" ]
                        then
                            g.remove vect=fire"$year"
                        fi
                        g.copy vect=a,fire"$year"
                        g.remove vect=a

#                        overlay the first 2 years
                        if [[ $year == 1942 ]]
                        then
                            if [ -d home/jn/Canada/Data/grassdata/ontario/FireSBW/vector/c ]
                            then
                                g.remove vect=c
                            fi
                                g.remove vect=c
                                g.copy vect=fire1941,a
                                g.copy vect=fire1942,b

                                v.overlay ainput=a atype=area binput=b btype=area output=c operator=or
                                echo "ALTER TABLE c DROP COLUMN a_cat"|db.execute
                                echo "ALTER TABLE c DROP COLUMN b_cat"|db.execute
                                echo "ALTER TABLE c RENAME COLUMN a_fire1941 TO fire1941"|db.execute
                                echo "ALTER TABLE c RENAME COLUMN b_fire1942 TO fire1942"|db.execute
                        fi

#                        overlay the following years
                        if [[ $year > 1942 ]]
                        then
                                g.remove vect=a
                                g.remove vect=b
                                g.copy vect=c,a
                                g.remove vect=c
                                g.copy vect=fire"$year",b
                                v.overlay ainput=a atype=area binput=b btype=area output=c operator=or
                                echo "ALTER TABLE c DROP COLUMN a_cat"|db.execute
                                echo "ALTER TABLE c DROP COLUMN b_cat"|db.execute
                                for ((year2 = 1941 ; year2 < $year ; year2++))
                                do
                                    echo "ALTER TABLE c RENAME COLUMN a_fire"$year2" TO fire"$year2""|db.execute
                                done
                                echo "ALTER TABLE c RENAME COLUMN b_fire"$year" TO fire"$year""|db.execute
                        fi
                else 
                    echo "ALTER TABLE c ADD COLUMN fire"$year" INT"|db.execute
                fi
        done
        g.remove vect=fire4105
        g.copy vect=c,fire4105
        for ((v=1921 ; v<=2005 ; v++))
        do
                g.remove vect=fire"$v"
        done
        g.remove vect=a,b,c
        for ((year=1941 ; year<=2005 ; year++))
        do
            echo $year
            echo "UPDATE fire4105 SET fire"$year" = 0 WHERE fire"$year" IS NULL"|db.execute
        done

}

TotalAreaBurned() {
# Calculate Total area burned per year for checking database
        rm area_burned_1941_2005.txt
        touch area_burned_1941_2005.txt
        rm fire4105.R
        g.remove vect=fire4105_analysis
        g.copy vect=fire4105,fire4105_analysis
        v.db.addcol map=fire4105_analysis columns="area double precision"
        v.to.db map=fire4105_analysis option=area col=area unit=h
        num=`v.info -c fire4105_analysis|wc -l`
        for ((i = 1941; i <= 2005; i++))
        do
            echo "$i `echo "select * from fire4105_analysis where fire"$i" = 1"|db.select|cut -d"|" -f"$num"|
            awk '$1 > 0 { sum = sum + $1} END {print sum}'`" >> area_burned_1941_2005.txt
        done
#        echo 'fire4105 <- read.table(file="area_burned_1941_2004.txt")' >> fire4105.R
#        echo 'fire4105.ts <- ts(fire4105[,2],start=1941,end=2005)' >> fire4105.R
#        echo 'pdf(file="fire4105.pdf")' >> fire4105.R
#           echo 'plot(fire4105.ts,xlab="Year",ylab="Area (ha)",main="Area burned in Ontario")' >> fire4105.R
#        echo 'dev.off()' >> fire4105.R
#        R --save < fire4105.R
        g.remove vect=fire4105_analysis
}

TotalAreaBurnedBelt() {
# Calculate Total area burned inside the budworm belt
        rm area_burned_1941_2004_sbwbelt.txt
        touch area_burned_1941_2004_sbwbelt.txt
        rm fire4105_sbwbelt.R
        g.remove vect=fire4105_sbwbelt
        v.select ainput=fire4105 atype=area binput=sbwbelt btype=area output=fire4105_sbwbelt
        v.db.addcol map=fire4105_sbwbelt columns="area double precision"
        v.to.db map=fire4105_sbwbelt option=area col=area unit=h
        num=`v.info -c fire4105_sbwbelt|wc -l`                
        for ((i = 1941; i <= 2005; i++))
        do
            echo "$i `echo "select * from fire4105_sbwbelt where fire"$i" = 1"|db.select|cut -d"|" -f"$num"| awk '$1 > 0 { sum = sum + $1} END {print sum}'`" >> area_burned_1941_2004_sbwbelt.txt
        done
#        echo 'fire4105_sbwbelt <- read.table(file="area_burned_1941_2004_sbwbelt.txt")' >> fire4105_sbwbelt.R
#        echo 'fire4105_sbwbelt.ts <- ts(fire4105_sbwbelt[,2],start=1941,end=2005)' >> fire4105_sbwbelt.R
#        echo 'pdf(file="fire4105_sbwbelt.pdf")' >> fire4105_sbwbelt.R
#   echo 'plot(fire4105_sbwbelt.ts,xlab="Year",ylab="Area (ha)",main="Area burned in Ontario inside sbw belt")' >> fire4105_sbwbelt.R
#        echo 'dev.off()' >> fire4105_sbwbelt.R
#        R --save < fire4105_sbwbelt.R
        g.remove vect=fire4105_sbwbelt
}

TotalAreaBurnedBeltByZone() {
# Calculate Total area burned inside the budworm belt, by zone
        rm area_burned_1941_2004_sbwbelt_byzone.txt
        touch area_burned_1941_2004_sbwbelt_byzone.txt
        rm fire4105_sbwbelt_byzone.R
        g.remove vect=fire4105_sbwbelt_byzone
        v.overlay ainput=fire4105_sbwbelt atype=area binput=defzone@sbw btype=area output=fire4105_sbwbelt_byzone operator=and
        for ((b=1941 ; b<=2005 ; b++))
        do
            echo "ALTER TABLE fire4105_sbwbelt_byzone RENAME COLUMN a_fire"$b" TO fire"$b""|db.execute
        done

        echo "ALTER TABLE fire4105_sbwbelt_byzone DROP COLUMN a_cat"|db.execute
        echo "ALTER TABLE fire4105_sbwbelt_byzone DROP COLUMN a_area"|db.execute
        echo "ALTER TABLE fire4105_sbwbelt_byzone DROP COLUMN b_cat"|db.execute
        echo "ALTER TABLE fire4105_sbwbelt_byzone DROP COLUMN b_valueid"|db.execute
        echo "ALTER TABLE fire4105_sbwbelt_byzone DROP COLUMN b_polyid"|db.execute
        echo "ALTER TABLE fire4105_sbwbelt_byzone DROP COLUMN b_area"|db.execute
        echo "ALTER TABLE fire4105_sbwbelt_byzone DROP COLUMN b_perimeter"|db.execute
        echo "ALTER TABLE fire4105_sbwbelt_byzone DROP COLUMN b_defzone_"|db.execute
        echo "ALTER TABLE fire4105_sbwbelt_byzone RENAME COLUMN b_defzone_id TO defzone_id"|db.execute
        v.db.addcol map=fire4105_sbwbelt_byzone columns="area double precision"
        v.to.db map=fire4105_sbwbelt_byzone option=area col=area unit=h
        num=`v.info -c fire4105_sbwbelt_byzone|wc -l`                
                
        for ((i = 1941; i <= 2005; i++))
        do
            echo "$i `echo "select * from fire4105_sbwbelt_byzone where fire"$i" = 1 and defzone_id = 3"|db.select|cut -d"|" -f"$num"| awk '$1 > 0 { sum = sum + $1} END {print sum}'` `echo "select * from fire4105_sbwbelt_byzone where fire"$i" = 1 and defzone_id = 4"|db.select|cut -d"|" -f"$num"| awk '$1 > 0 { sum = sum + $1} END {print sum}'` `echo "select * from fire4105_sbwbelt_byzone where fire"$i" = 1 and defzone_id = 5"|db.select|cut -d"|" -f"$num"| awk '$1 > 0 { sum = sum + $1} END {print sum}'`" >> area_burned_1941_2004_sbwbelt_byzone.txt
        done
}

TotalAreaBurnedOutBelt() {
# Calculate Total area burned outside the budworm belt
        rm area_burned_1941_2004_outside_sbwbelt.txt
        touch area_burned_1941_2004_outside_sbwbelt.txt
        rm fire4105_outside_sbwbelt.R
        g.remove vect=fire4105_outside_sbwbelt
        v.overlay ainput=fire4105 atype=area binput=sbwbelt btype=area operator=not output=fire4105_outside_sbwbelt
        v.db.addcol map=fire4105_outside_sbwbelt columns="area double precision"
        v.to.db map=fire4105_outside_sbwbelt option=area col=area unit=h
        num=`v.info -c fire4105_outside_sbwbelt|wc -l`                
        for ((i = 1941; i <= 2005; i++))
        do
            echo "$i `echo "select * from fire4105_outside_sbwbelt where a_fire"$i" = 1"|db.select|cut -d"|" -f"$num"| 
            awk '$1 > 0 { sum = sum + $1} END {print sum}'`" >> area_burned_1941_2004_outside_sbwbelt.txt
        done
        echo 'fire4105_outside_sbwbelt <- read.table(file="area_burned_1941_2004_outside_sbwbelt.txt")' >> fire4105_outside_sbwbelt.R
        echo 'fire4105_outside_sbwbelt.ts <- ts(fire4105_outside_sbwbelt[,2],start=1941,end=2005)' >> fire4105_outside_sbwbelt.R
        echo 'pdf(file="fire4105_outside_sbwbelt.pdf")' >> fire4105_outside_sbwbelt.R
   echo 'plot(fire4105_sbwbelt.ts,xlab="Year",ylab="Area (ha)",main="Area burned in Ontario outside the sbw belt")' >> fire4105_outside_sbwbelt.R
        echo 'dev.off()' >> fire4105_outside_sbwbelt.R
        R --save < fire4105_outside_sbwbelt.R
}

FireFreq() {
# Build coverage of frequency of fire
        g.copy vect=fire4105,fire4105_freq 

        echo "ALTER TABLE fire4105_freq ADD COLUMN freqfire integer"|db.execute

        sqlcom="UPDATE fire4105_freq SET freqfire="
        for ((year=1941 ; year<=2005 ; year++))
        do
            sqlcom=$sqlcom"fire"$year"+"
        done
        sqlcom=`echo $sqlcom|sed 's/+$//'`
        echo $sqlcom|db.execute

        for ((year=1941 ; year<=2005 ; year++))
        do
            echo "ALTER TABLE fire4105_freq DROP COLUMN fire"$year""|db.execute
        done
}

FiresPerYear() {
# Calculate the number of fires per year over entire Ontario
        rm number_fires_1941_2004.txt
        touch number_fires_1941_2004.txt
        for ((i = 1941; i <= 1979; i++))
        do
            endyear=${i:2:4}
            echo "$i `v.db.select -c fire"$i"@fire column=ON"$endyear"_ID | sort | uniq | wc -l`" >> number_fires_1941_2004.txt
        done
        for ((i = 1980; i <= 2005; i++))
        do
            echo "$i `v.db.select -c fire"$i"@fire column=CFS_FIREID | sort | uniq | wc -l`" >> number_fires_1941_2004.txt
        done
}

FiresPerYearBelt() {
# Calculate the number of fires per year inside the budworm belt
        rm number_fires_1941_2004_sbwbelt.txt
        touch number_fires_1941_2004_sbwbelt.txt
        for ((i = 1941; i <= 1979; i++))
        do
            g.remove vect=a
            v.overlay ainput=fire"$i"@fire atype=area binput=defzone@sbw btype=area output=a operator=and                        
            endyear=${i:2:4}
            echo "$i `v.db.select -c a column=a_ON"$endyear"_ID | sort | uniq | wc -l`" >> number_fires_1941_2004_sbwbelt.txt
        done
        for ((i = 1980; i <= 2005; i++))
        do
            g.remove vect=a
            v.overlay ainput=fire"$i"@fire atype=area binput=defzone@sbw btype=area output=a operator=and                        
            echo "$i `v.db.select -c a column=a_CFS_FIREID | sort | uniq | wc -l`" >> number_fires_1941_2004_sbwbelt.txt
        done
        g.remove vect=a
}


###########################################
# Import bioclimatic variables 
###########################################
g.region res=10000
ImportFRI() {
        g.copy rast=fri0899_HW@FRI,HW1
        r.mapcalc "HW=HW1*100.0"
        g.copy rast=fri0899_FbSw@FRI,FbSw1
        r.mapcalc "FbSw=FbSw1*100.00"
        g.copy rast=fri0899_FbSwSb@FRI,FbSwSb1
        r.mapcalc "FbSwSb=FbSwSb1*100.00"
        g.remove rast=HW1,FbSw1,FbSwSb1
}


ImportClimate() {
        for ((v=1 ; v<=12 ; v++))
        do
                g.copy rast=maxt"$v"@climate,maxt"$v"
                g.copy rast=mint"$v"@climate,mint"$v"
                g.copy rast=pcp"$v"@climate,pcp"$v"
        done
}

ImportCMI() {
# CMI
## Create Location for import of CMI grids from Price
## Projection:
##        name: Lambert Conformal Conic
##        proj: lcc
##        ellps: grs80
##        a: 6378137.0000000000
##        es: 0.0066943800
##        f: 298.2572221010
##        lat_0: 23.0000000000
##        lat_1: 49.0000000000
##        lat_2: 77.0000000000
##        lon_0: -95.0000000000
##        x_0: 0.0000000000
##        y_0: 0.0000000000
## Extent:
##        north:      7350500
##        south:      5700500
##        east:       -1010500
##        west:       -2600500
##        cols:       159
##        rows:       165
##        e-w resol:  10000
##        n-s resol:  10000

        g.gisenv set=GISDBASE=/home/jn/Canada/Data/grassdata
        g.gisenv set=LOCATION_NAME=CMI
        g.gisenv set=MAPSET=PERMANENT
        
        r.in.arc input=/home/jn/Canada/Data/Climate/Price_annual/histv2_cmi4_rf_pmw_nov-oct_ont_1941-2003ave.asg output=cmi_ave type=FCELL mult=1.0 
        for ((v=1941 ; v<=2003 ; v++))
        do
                r.in.arc input=/home/jn/Canada/Data/Climate/Price_annual/histv2_cmi4_rf_pmw_nov-oct_ont_1941-2003yearly.zip_FILES/histv2_cmi4_rf_pmw_nov-oct_ont_"$v".asg output=cmi_"$v" type=FCELL mult=1.0
        done

        g.gisenv set=GISDBASE=/home/jn/Canada/Data/grassdata
        g.gisenv set=LOCATION_NAME=ontario
        g.gisenv set=MAPSET=FireSBW
                
        r.proj input=cmi_ave location=CMI mapset=PERMANENT output=cmi_ave
        for ((v=1941 ; v<=2003 ; v++))
        do
                r.in.arc input=/home/jn/Canada/Data/Climate/Price_annual/histv2_cmi4_rf_pmw_nov-oct_ont_1941-2003yearly.zip_FILES/histv2_cmi4_rf_pmw_nov-oct_ont_"$v".asg output=cmi_"$v" type=FCELL mult=1.0
        done
}


###########################################
# Union of sbw and fire coverages
###########################################
UnionSbwFire() {
        g.remove vect=sbwfire
        v.overlay ainput=sbw4105 atype=area binput=fire4105 btype=area output=sbwfire operator=or
        echo "ALTER TABLE sbwfire DROP COLUMN a_cat"|db.execute
        echo "ALTER TABLE sbwfire DROP COLUMN b_cat"|db.execute
        num=`db.describe -c sbwfire|wc -l`
        for ((x=2 ; x<=num ; x++))
        do
                echo $x
                colname=`db.columns sbwfire | head -"$x" | tail -1`
                colname2=`echo $colname|sed 's/a_//'|sed 's/b_//'`
                echo "ALTER TABLE sbwfire RENAME COLUMN "$colname" TO "$colname2""|db.execute
        done
# upload polygons areas in a new column
#        Create column
        echo "ALTER TABLE sbwfire ADD COLUMN area double precision"|db.execute

#        upload areas in hectares
        v.to.db map=sbwfire option=area col=area unit=h

        echo "SELECT * FROM sbwfire"|db.select| sed -e "s/|/,/g" | sed -e "s/,,/,0,/g" | sed -e "s/,,/,0,/g" > sbwfire_x.txt
        num=`wc -l sbwfire_x.txt | cut -f1 -d" "`
        let "num2=num-1"
        tail -"$num2" sbwfire_x.txt > sbwfire.txt

        echo "DELETE FROM sbwfire"|db.execute

        cp sbwfire.txt /tmp
        echo "COPY sbwfire FROM '/tmp/sbwfire.txt' USING DELIMITERS ','"|db.execute
}


###########################################
# Lag analysis
###########################################
#############
# In Fortran
#############
LagAnalysisFortran() {
g.remove vect=sbwfire1
g.copy vect=sbwfire,sbwfire1
echo "ALTER TABLE sbwfire1 ADD COLUMN lag integer"|db.execute
echo "UPDATE sbwfire1 SET lag = 0"|db.execute

# export in text file, replace delimiter by "," and empty fields by "-99"
echo "SELECT * FROM sbwfire1"|db.select| sed "s/|/,/g" > sbwfire1.txt

ExtractFile \#cCOMPUTE_LAG_BEGIN \#COMPUTE_LAG_END ComputeLag.f
#cCOMPUTE_LAG_BEGIN
# c      ComputeLag.f
# c        This program reads the records of sbw and fire from 1941 to 2005
# c      and checks if there is a lag or not
# 
#        PROGRAM ComputeLags 
#        CHARACTER*8 A(134) 
#        INTEGER CAT,SBW(65),FIRE(65),LAG,LAGWIND(3)
#              INTEGER LAGBOUND(3:5,2),FIRES
#              INTEGER DEFLAG(3),OUTBRK1,OUTBRK2
#              REAL*8 AREA,RANF
#              DATA LAGBOUND(3,1),LAGBOUND(3,2)/3,6/
#              DATA LAGBOUND(4,1),LAGBOUND(4,2)/6,16/
#              DATA LAGBOUND(5,1),LAGBOUND(5,2)/4,9/
#              DATA LAGWIND(1),LAGWIND(2),LAGWIND(3)/5,10,20/
#        OPEN(UNIT=1, FILE='sbwfire1.txt', STATUS='OLD') 
#        OPEN(UNIT=2, FILE='sbwfirelag_F.txt') 
# 
# c Take care of the header
#       READ(UNIT=1,FMT=*) (A(I), I=1,134)
# c      WRITE(2,98) (A(I), I=1,134)
# c Loop over the rows (71412 rows in sbwfire4b.txt)
# 
#       DO 5 I=1,76097
#              READ(1,*) CAT,(SBW(J), J=1,65),IDEFZ,(FIRE(K), K=1,65),AREA,LAG
#          LAG = 0
#          IF (IDEFZ.GE.3.AND.IDEFZ.LE.5) THEN
#             JMAX = 65-LAGBOUND(IDEFZ,1)
#             DO 20 J=1,JMAX
#              IF (SBW(J).GT.0.AND.SBW(J+1).EQ.0) THEN
#                 KMAX = MIN(65-J,LAGBOUND(IDEFZ,2))
#                 DO 30 K=LAGBOUND(IDEFZ,1),KMAX
#                   IF (FIRE(J+K).GT.0) THEN
#                      LAG = 1
#                   ENDIF
#  30                CONTINUE
#              ENDIF
#  20            CONTINUE
#          ENDIF
# c   1       write(2,97) CAT,LAG
#   1       write(2,99) CAT,(SBW(J), J=1,65),IDEFZ,(FIRE(K), K=1,65),
#      c            AREA,LAG
#   5       CONTINUE
# 
#  97       FORMAT(I6,',',I1)
#  98       FORMAT(135(A8,','),A8)
#  99       FORMAT(I6,',',65(I1,','),I3,',',65(I1,','),F13.6,1(',',I2))
#        END 
#COMPUTE_LAG_END

g77 -O -o ComputeLag ComputeLag.f

# Run SlidingWindow.f
./ComputeLag

# Supprimer les espaces crees pas ComputeLag
sed -e "s/ //g"  > a
mv a sbwfirelag_F.txt

# Remove all the rows from sbwfire1
echo "DELETE FROM sbwfire1"|db.execute

# Fill up again with new data
# Needs to move the file to /tmp because user postgres cannot access my directories
cp sbwfirelag_F.txt /tmp
echo "COPY sbwfire1 FROM '/tmp/sbwfirelag_F.txt' USING DELIMITERS ','"|db.execute

}

##############################################################################
# Analysis #1: fire within sbw lag vs no fire at 10km:
#  1- work at 10km
#  2- use all the fire-sbw lags available and take 600 sample pts outside 
#  3- in areas with several fires, we consider as positive fire-sbw lag when 
#     there has been at least one fire-sbw lag (we use sbwfire2 created in
#     the procedure above)
##############################################################################
Analysis_1() {

Analysis_1_1() {
g.region res=10000 vect=sbw4105

# Create mask for sampling: take one raster from each type and add them all. This way
# we are sure that we will not have missing data at the end
v.to.rast --o input=sbw4105_freq output=sbwfreq use=attr column=freqdef
r.mapcalc "mask1=mint1+cmi_ave+FbSw+sbwfreq"
r.mask -o input=mask1

### Need to extract areas with lag > 1 in new coverage then dissolve and then apply
### v.to.rast to get the most accurate result (otherwise v.to.rast seems to behave
### stangely)
v.extract --o input=sbwfire1 type=area output=sbwfire1_lag where="lag > 0"
v.to.rast --o input=sbwfire1_lag output=tmp use=val value=1

### Extract areas inside the budworm belt (defzone > 0) then convert to raster, all the cells
### are coded with 0 so when adding the cells coded 1 for the fire-lag, we have the binary dataset
v.extract --o -d input=sbwfire1 type=area layer=1 new=0 output=sbwfire1_defzone  where="defzone > 0"
v.to.rast --o input=sbwfire1_defzone output=defzone use=val value=0

r.mapcalc 'sbwfire1_lag_nolag = if(isnull(tmp),0,tmp) + defzone'
### At 10km there are 3415 cells with no lag and 450 cells with lag

### Create mask for no lag
r.mapcalc 'sbwfire1_nolag = if(sbwfire1_lag_nolag == 0,sbwfire1_lag_nolag,null())'
}

Analysis_1_2() {
# Sample 450 cells from no-fire-sbw-lag raster
g.remove rast=sbwfire1_nolag_rand
g.remove vect=sbwfire1_nolag_rand
r.random --o input=sbwfire1_nolag n=450 raster_output=sbwfire1_nolag_rand vector_output=sbwfire1_nolag_rand

# Raster of fire-sbw lag (value=1) and sample of cells (459) with no fire-sbw lag 
r.mapcalc 'sbwfire1_rand = if(sbwfire1_lag_nolag,tmp,sbwfire1_nolag_rand)'
r.to.vect --o input=sbwfire1_rand output=sbwfire1_rand feature=point

# Import climate data
for ((v=1 ; v<=12 ; v++))
do
echo "ALTER TABLE sbwfire1_rand ADD COLUMN mint"$v" float "|db.execute
v.what.rast vect=sbwfire1_rand rast=mint"$v" col=mint"$v"
echo "ALTER TABLE sbwfire1_rand ADD COLUMN maxt"$v" float"|db.execute
v.what.rast vect=sbwfire1_rand rast=maxt"$v" col=maxt"$v"
echo "ALTER TABLE sbwfire1_rand ADD COLUMN pcp"$v" float"|db.execute
v.what.rast vect=sbwfire1_rand rast=pcp"$v" col=pcp"$v"
done

# Import CMI
echo "ALTER TABLE sbwfire1_rand ADD COLUMN cmi_ave float" |db.execute
v.what.rast vect=sbwfire1_rand rast=cmi_ave col=cmi_ave

#Import frequency of defoliation 1941-2005
echo "ALTER TABLE sbwfire1_rand ADD COLUMN sbwfreq integer" |db.execute
v.what.vect vect=sbwfire1_rand qvector=sbw4105_freq column=sbwfreq qcolumn=freqdef

# Import FRI data
echo "ALTER TABLE sbwfire1_rand ADD COLUMN FbSw float" |db.execute
v.what.rast vect=sbwfire1_rand rast=FbSw col=fbsw
echo "ALTER TABLE sbwfire1_rand ADD COLUMN FbSwSb float" |db.execute
v.what.rast vect=sbwfire1_rand rast=FbSwSb col=fbswsb
echo "ALTER TABLE sbwfire1_rand ADD COLUMN HW float" |db.execute
v.what.rast vect=sbwfire1_rand rast=HW col=hw

g.remove vect=sbwfire1_defzone,sbwfire1_nolag_rand
g.remove rast=defzone,sbwfire1_lag_nolag,sbwfire1_nolag,sbwfire1_nolag_rand,sbwfire1_rand

}

# Remove mask
r.mask -r MASK

}

Resampling_random_points_1() {
# execute the first part of Analysis_1
Analysis_1_1

# resample the random points in the seconf part of Analysis_1
for ((i=1 ; i <=50 ; i++))
do
    Analysis_1_2
    g.remove vect=sbwfire1b_"$i"_rand
    g.copy vect=sbwfire1_rand,sbwfire1b_"$i"_rand
done

# Adding Pines and Sb to previous sbwfire1b_"$i"_rand
for ((i=1 ; i <=50 ; i++))
do
    g.remove vect=sbwfire1c_"$i"_rand
    g.remove vect=tempc
    g.copy vect=sbwfire1b_"$i"_rand,tempc
    echo "ALTER TABLE tempc ADD COLUMN Pines float" |db.execute
    v.what.rast vect=tempc rast=Pines col=pines
    echo "ALTER TABLE tempc ADD COLUMN Sb float" |db.execute
    v.what.rast vect=tempc rast=Sb col=sb
    g.copy vect=tempc,sbwfire1c_"$i"_rand 
done

# Save the different layers in resampli,g directory
# for ((i=1 ; i <=50 ; i++))
# do
#     v.out.ogr input=sbwfire1b_"$i"_rand type=point dsn=/home/jn/Canada/FireSBW/Analyses_Dec06/resampling olayer=sbwfire1b_"$i"_rand format=ESRI_Shapefile
# done

}

#####################################
## R Analysis
#####################################

Resampling_1_R() {
library(rpart)
library(maptree)
library(fields)
library(RODBC)
channel <- odbcConnect("grassdb","jn","budworm1",case="postgresql")

autoprune <- function(tree) {
    xerr <- tree$cptable[,"xerror"]
    cpmin.id <- which.min(xerr)
    
    xstd <- tree$cptable[,"xstd"]
    errt <- xerr[cpmin.id] + xstd[cpmin.id]
    cpSE1.min <- which.min(errt < xerr)
    mycp <- (tree$cptable[,"CP"])[cpSE1.min]
    
    return(mycp)
}

pdf(file="test50.pdf")

for(i in 1:50) {
	sbwfire1_rand <- sqlFetch(channel,paste("sbwfire1b_",i,"_rand",sep=""))
	sbwfire1.rpart <- rpart(value~.,data=sbwfire1_rand[,c("value","sbwfreq","cmi_ave","fbsw","fbswsb","hw")],method="class",cp=0)
	sbwfire1.rpart.p <- prune(sbwfire1.rpart,cp=autoprune(sbwfire1.rpart))
        sbwfire1.rpart.p$splits[,"index"] <-  round(sbwfire1.rpart.p$splits[,"index"],digits=1)
        draw.tree(sbwfire1.rpart.p,nodeinfo=T,pch=16,units="interaction",cases="cells",cex=.8)
}

dev.off()

}

Plot_sbwfires_map_R() {
# Plot the sbw-fires on a map
system('v.extract --o input=sbwfire1 type=area output=sbwfire1_lag where="lag > 0"')
system("v.to.rast --o input=sbwfire1_lag output=tmp use=val value=1")
system('v.extract --o -d input=sbwfire1 type=area layer=1 new=0 output=sbwfire1_defzone  where="defzone > 0"')
system("v.to.rast --o input=sbwfire1_defzone output=defzone use=val value=0")
system("r.mapcalc 'sbwfire1_lag_nolag = if(isnull(tmp),0,tmp) + defzone'")
library(spgrass6)
G <- gmeta6()
if (!exists("ontario")) {
ontario <- readVECT6("ontario@basemaps")
}
lag_nolag.map <- readRAST6("sbwfire1_lag_nolag")
if (!exists("sbwfire1_lag")) {
sbwfire1_lag <- readVECT6("sbwfire1_lag")
}

pdf("Figure7.pdf", paper="letter")
image(lag_nolag.map,col=c("blue","red"))
plot(ontario,add=T)
legend("bottomleft",legend=c("no fire or no sbw-fire","sbw-fire"),fill=c("blue","red"),title="",cex=0.7)
dev.off()
}


Classification_tree_1_R() {
library(rpart)
library(maptree)
library(fields)
library(RODBC)
channel <- odbcConnect("grassdb","jn","budworm1",case="postgresql")
# Note: the results of a single regression tree can change from one run to the next (see below about unstable trees)
# To avoid having to change the description of the RT every time, we use always the same tree
# From the result of the resampling above, we selected the "best looking" tree (good classification rate without being
# too complex). The tree built on iteration #17 looked the best. We also set the seed to avoid variations of the pruning
# process from run to run.
# All the layers from the resampling (including #17 used hereafter) are saved in the resampling directory in shapefile format

sbwfire1_rand <- sqlFetch(channel,"sbwfire1b_17_rand")

autoprune <- function(tree) {
    xerr <- tree$cptable[,"xerror"]
    cpmin.id <- which.min(xerr)
    
    xstd <- tree$cptable[,"xstd"]
    errt <- xerr[cpmin.id] + xstd[cpmin.id]
    cpSE1.min <- which.min(errt < xerr)
    mycp <- (tree$cptable[,"CP"])[cpSE1.min]
    
    return(mycp)
}

set.seed(120)

sbwfire1.rpart <- rpart(value~.,data=sbwfire1_rand[,c("value","sbwfreq","cmi_ave","fbsw","fbswsb","hw")],method="class",cp=0)
sbwfire1.rpart.p <- prune(sbwfire1.rpart,cp=0.020)

# Reduce the number of digits to 1
sbwfire1.rpart.p$splits[,"index"] <-  round(sbwfire1.rpart.p$splits[,"index"],digits=1)

pdf("Figure8.pdf", paper="letter")
library(maptree)
draw.tree.jn(sbwfire1.rpart.p,nodeinfo=T,col=tim.colors(6),pch=16,units="interaction",cases="cells",cex=.8)
dev.off()

# Plot tree leaves on a map
## Create the map of different splits
system("r.mapcalc 'tree1 = if(HW >= 54.4,1,0)'")
system("r.mapcalc 'tree1 = if(tree1 == 0 && FbSwSb >= 77.6,2,tree1)'")
system("r.mapcalc 'tree1 = if(tree1 == 0 && cmi_ave <= 33.2,3,tree1)'")
system("r.mapcalc 'tree1 = if(tree1 == 0 && cmi_ave < 45.1,6,tree1)'")
system("r.mapcalc 'tree1 = if(tree1 == 0 && sbwfreq < 8.5,4,tree1)'")
system("r.mapcalc 'tree1 = if(tree1 == 0 && sbwfreq > 8.5,5,tree1)'")
## Plot
pdf("Figure9.pdf", paper="letter")
library(spgrass6)
G <- gmeta6()
if (!exists("ontario")) {
ontario <- readVECT6("ontario@basemaps")
}
tree.map <- readRAST6("tree1")
image(tree.map,col=tim.colors(6))
plot(ontario,add=T,lwd=1.5)
legend("bottomleft",legend=c("1","2","3","4","5","6"),fill=tim.colors(6),title="Leaves number")
dev.off()

# Distribution of number of terminal leaves depending on the effect of the random number generator on the
# pruning algorithm
imax <- 50
num_leaves <- rep(NA,imax)
for (i in 1:imax)
{
sbwfire1b.rpart <- rpart(value~.,data=sbwfire1_rand[,c("value","sbwfreq","cmi_ave","fbsw","fbswsb","hw")],method="class",cp=0)
sbwfire1b.rpart.p <- prune(sbwfire1b.rpart,cp=autoprune(sbwfire1b.rpart))
num_leaves[i] <- length(sbwfire1b.rpart.p$frame$var[sbwfire1b.rpart.p$frame$var == "<leaf>"])
}
pdf("Figure10.pdf",paper="letter")
barplot(table(num_leaves)/imax,ylab="Frequency",xlab="Tree size")
dev.off()

# RandomForest
library(randomForest)
sbwfire1.rf <- randomForest(factor(value)~.,data=sbwfire1_rand[,c("value","sbwfreq","cmi_ave","fbsw","fbswsb","hw")],na.action=na.omit,importance=T)
pdf("Figure11.pdf",paper="letter")
varImpPlot(sbwfire1.rf,type=1,main="Importance according to mean decrease accuracy")
dev.off()

# Classification tree on the 2 best variables from the random forest = cmi_ave and sbwfreq
sbwfire1c.rpart <- rpart(value~.,data=sbwfire1_rand[,c("value","sbwfreq","cmi_ave")],method="class",cp=0)
sbwfire1c.rpart.p <- prune(sbwfire1c.rpart,cp=autoprune(sbwfire1c.rpart))
# Reduce the number of digits to 1
sbwfire1c.rpart.p$splits[,"index"] <-  round(sbwfire1c.rpart.p$splits[,"index"],digits=1)
pdf("Figure12.pdf", paper="letter")
library(maptree)
draw.tree(sbwfire1c.rpart.p,nodeinfo=T,col=tim.colors(11),pch=16,units="interaction",cases="cells",cex=.7)
dev.off()

# Bootstrap analysis of classification trees
library(RODBC)
library(rpart)
library(randomForest)
channel <- odbcConnect("grassdb","jn","budworm1",case="postgresql")

variables <- NA
num_leaves <- NA
correct_classif <- NA
randomForest_rank <- NA

for(i in 1:50) {
	sbwfire1_rand <- sqlFetch(channel, paste("sbwfire1b_",i,"_rand",sep=""))

	sbwfire1.rpart <- rpart(value~.,data=sbwfire1_rand[,c("value","sbwfreq","cmi_ave","fbsw","fbswsb","hw")],method="class",cp=0)
	sbwfire1.rpart.p <- prune(sbwfire1.rpart,cp=autoprune(sbwfire1.rpart))

	variables <- c(variables,as.vector(sbwfire1.rpart.p$frame$var[sbwfire1.rpart.p$frame$var != "<leaf>"]))

	num_leaves <- c(num_leaves,length(sbwfire1.rpart.p$frame$var[sbwfire1.rpart.p$frame$var == "<leaf>"]))

	correct_classif <- c(correct_classif,classified.rate.tree(sbwfire1.rpart.p))

	sbwfire1.rf <- randomForest(factor(value)~.,data=sbwfire1_rand[,c("value","sbwfreq","cmi_ave","fbsw","fbswsb","hw")],na.action=na.omit,importance=T)

	a <- 6-rank(sbwfire1.rf$importance[,3])
	randomForest_rank <- c(randomForest_rank,a)
	
}

variables <- variables[-1]
num_leaves <- num_leaves[-1]
correct_classif <- correct_classif[-1]
randomForest_rank <- randomForest_rank[-1]

pdf("Figure13.pdf", paper="letter")
hist(100-correct_classif,xlab="Misclassification error rate",main="",col="grey")
dev.off()

pdf("Figure14.pdf", paper="letter")
barplot(table(num_leaves),xlab="Number of terminal leaves",ylab="Frequency")
dev.off()

pdf("Figure15.pdf", paper="letter")
barplot(table(variables),xlab="Variable retained in the classification tree",ylab="Frequency")
dev.off()

pdf("Figure16.pdf", paper="letter")
par(mfrow=c(3,2))
a <- tapply(randomForest_rank,names(randomForest_rank),function(x) table(x))
barplot(a$cmi_ave,xlab="cmi_ave",ylab="Frequency")
barplot(a$fbsw,xlab="fbsw",ylab="Frequency")
barplot(a$fbswsb,xlab="fbswsb",ylab="Frequency")
barplot(a$hw,xlab="hw",ylab="Frequency")
barplot(a$sbwfreq,xlab="sbwfreq",ylab="Frequency")
dev.off()

# Predict over the entire dataset for 50 different classification trees and make a map of probability
# of being a cell with sbw - fire interaction

system("g.region res=10000 vect=sbw4105")
system("v.to.rast --o input=sbw4105_freq output=sbwfreq use=attr column=freqdef")
system('r.mapcalc "mask1=mint1+cmi_ave+FbSw+sbwfreq"')
system("r.mask -o input=mask1")
system('v.extract --o input=sbwfire1 type=area output=sbwfire1_lag where="lag > 0"')
system("v.to.rast --o input=sbwfire1_lag output=tmp use=val value=1")
system('v.extract --o -d input=sbwfire1 type=area layer=1 new=0 output=sbwfire1_defzone  where="defzone > 0"')
system("v.to.rast --o input=sbwfire1_defzone output=defzone use=val value=0")
system("r.mapcalc 'sbwfire1_lag_nolag = if(isnull(tmp),0,tmp) + defzone'")

system("r.to.vect --o input=sbwfire1_lag_nolag output=sbwfire1_lag_nolag feature=point")
system('echo "ALTER TABLE sbwfire1_lag_nolag ADD COLUMN cmi_ave float" |db.execute')
system("v.what.rast vect=sbwfire1_lag_nolag rast=cmi_ave col=cmi_ave")
system('echo "ALTER TABLE sbwfire1_lag_nolag ADD COLUMN sbwfreq integer" |db.execute')
system("v.what.vect vect=sbwfire1_lag_nolag qvector=sbw4105_freq column=sbwfreq qcolumn=freqdef")
system('echo "ALTER TABLE sbwfire1_lag_nolag ADD COLUMN FbSw float" |db.execute')
system("v.what.rast vect=sbwfire1_lag_nolag rast=FbSw col=fbsw")
system('echo "ALTER TABLE sbwfire1_lag_nolag ADD COLUMN FbSwSb float" |db.execute')
system("v.what.rast vect=sbwfire1_lag_nolag rast=FbSwSb col=fbswsb")
system('echo "ALTER TABLE sbwfire1_lag_nolag ADD COLUMN HW float" |db.execute')
system("v.what.rast vect=sbwfire1_lag_nolag rast=HW col=hw")

tmp <- sqlFetch(channel, "sbwfire1_lag_nolag")

a <- rep(0,dim(tmp)[1])

for(i in 1:50) {

    sbwfire1_rand <- sqlFetch(channel,paste("sbwfire1b_",i,"_rand",sep=""))

    sbwfire1.rpart <- rpart(value~.,data=sbwfire1_rand[,c("value","sbwfreq","cmi_ave","fbsw","fbswsb","hw")],method="class",cp=0)
    sbwfire1.rpart.p <- prune(sbwfire1.rpart,cp=autoprune(sbwfire1.rpart))

    a <- a + (as.numeric(predict(sbwfire1.rpart.p,newdata=tmp,type="class"))-1)

}

a <- a/50

system("g.remove vect=predicted1_rf")
sqlSave(channel,data.frame(cat=tmp$cat,predicted=a),"predicted1_rf")

# In GRASS
system("g.copy vect=sbwfire1_lag_nolag,predicted1_rf")
system("v.db.connect -o map=predicted1_rf table=predicted1_rf key=cat layer=1")

system("v.to.rast input=predicted1_rf output=predicted1_rf use=attr column=predicted")

library(spgrass6)
G <- gmeta6()

predicted1_rf.map <- readRAST6("predicted1_rf")
library(fields)
a <- pretty(unique(predicted1_rf.map[[1]],na.rm=T))
if (!exists("ontario")) {
ontario <- readVECT6("ontario@basemaps")
}

pdf("Figure17.pdf", paper="letter")
image(predicted1_rf.map,col=tim.colors(length(a)))
plot(ontario,add=T,lwd=1.5)
legend("bottomleft",legend=a,fill=tim.colors(length(a)),title="Prob. of sbw-fire interaction",cex=0.7)
dev.off()

}

##################################################################################################
# Analysis of sbw fire interaction #2
#
# In this analysis, we characterize the bioclimatic conditions of areas burned with a spruce
# budwom interaction with areas burned without fire interaction 
###################################################################################################
Analysis_2() {

# Calculate the number of fires
g.remove vect=sbwfire2
g.copy vect=sbwfire1,sbwfire2
echo "ALTER TABLE sbwfire2 ADD COLUMN fires int"|db.execute
sqlcom="UPDATE sbwfire2 SET fires="
for ((year=1941 ; year<=2005 ; year++))
do
        yy=`db.columns sbwfire1| grep fire"$year"`
        if [[ $yy == fire$year ]]
        then
                sqlcom=$sqlcom"fire"$year"+"
        fi
done
sqlcom=`echo $sqlcom|sed 's/+$//'`
echo $sqlcom|db.execute

g.region res=10000 vect=sbw4105

Analysis_2_1() {
### Extract areas inside the budworm belt (defzone > 0) then convert to raster, all the cells
### are coded with 0 so when adding the cells coded 1 for the fire-lag, we have the binary dataset
v.extract --o input=sbwfire2 type=area output=sbwfire2_lag where="lag > 0"
v.to.rast --o input=sbwfire2_lag output=tmp use=val value=2

### Extract areas inside the budworm belt (defzone > 0) then convert to raster, all the cells
### are coded with 0 so when adding the cells coded 1 for the fire-lag, we have the binary dataset
v.extract --o -d input=sbwfire2 type=area output=sbwfire2_nolag  where="lag=0 and fires>0"
v.to.rast --o input=sbwfire2_nolag output=tmp2 use=val value=1

r.mapcalc 'tmp3 = if(isnull(tmp),0,tmp)'
r.mapcalc 'tmp4 = if(isnull(tmp2),0,tmp2)'

r.mapcalc 'tmp5 = tmp3 + tmp4'
r.mapcalc 'sbwfire2_lag_nolag = if(tmp5==3,2,tmp5)'
g.remove rast=tmp,tmp2,tmp3,tmp4,tmp5
### At 10km there are 719 cells with no lag and 450 cells with lag

### Create mask for no lag
r.mapcalc 'sbwfire2_nolag = if(sbwfire2_lag_nolag == 1,sbwfire2_lag_nolag,null())'
}

Analysis_2_2() {
g.remove rast=sbwfire2_nolag_rand
g.remove vect=sbwfire2_nolag_rand
r.random --o input=sbwfire2_nolag n=450 raster_output=sbwfire2_nolag_rand vector_output=sbwfire2_nolag_rand

r.mapcalc 'tmp5 = if(sbwfire2_lag_nolag==2,2,0) + if(isnull(sbwfire2_nolag_rand),0,1)'
r.mapcalc 'sbwfire2_rand = if(tmp5==0,null(),tmp5)'
r.to.vect --o input=sbwfire2_rand output=sbwfire2_rand feature=point

g.remove rast=sbwfire2_lag_nolag,sbwfire2_nolag,sbwfire2_nolag_rand
g.remove vect=sbwfire2_lag,sbwfire2_nolag,sbwfire2_nolag_rand

# Import climate data
# for ((v=1 ; v<=12 ; v++))
# do
# echo "ALTER TABLE sbwfire2_rand ADD COLUMN mint"$v" float "|db.execute
# v.what.rast vect=sbwfire2_rand rast=mint"$v" col=mint"$v"
# echo "ALTER TABLE sbwfire2_rand ADD COLUMN maxt"$v" float"|db.execute
# v.what.rast vect=sbwfire2_rand rast=maxt"$v" col=maxt"$v"
# echo "ALTER TABLE sbwfire2_rand ADD COLUMN pcp"$v" float"|db.execute
# v.what.rast vect=sbwfire2_rand rast=pcp"$v" col=pcp"$v"
# done

#Import frequency of defoliation 1941-2005
echo "ALTER TABLE sbwfire2_rand ADD COLUMN sbwfreq integer" |db.execute
v.what.vect vect=sbwfire2_rand qvector=sbw4105_freq column=sbwfreq qcolumn=freqdef

# Import CMI
echo "ALTER TABLE sbwfire2_rand ADD COLUMN cmi_ave float" |db.execute
v.what.rast vect=sbwfire2_rand rast=cmi_ave col=cmi_ave

# Import FRI data
echo "ALTER TABLE sbwfire2_rand ADD COLUMN FbSw float" |db.execute
v.what.rast vect=sbwfire2_rand rast=FbSw col=fbsw
echo "ALTER TABLE sbwfire2_rand ADD COLUMN FbSwSb float" |db.execute
v.what.rast vect=sbwfire2_rand rast=FbSwSb col=fbswsb
echo "ALTER TABLE sbwfire2_rand ADD COLUMN HW float" |db.execute
v.what.rast vect=sbwfire2_rand rast=HW col=hw
}

# Make a coverage with all the data (no sampling) to use in prediction
# of Random Forest
v.extract --o input=sbwfire2 type=area output=sbwfire2_lag where="lag > 0"
v.to.rast --o input=sbwfire2_lag output=tmp use=val value=2
v.extract --o -d input=sbwfire2 type=area output=sbwfire2_nolag  where="lag=0 and fires>0"
v.to.rast --o input=sbwfire2_nolag output=tmp2 use=val value=1
r.mapcalc 'tmp3 = if(isnull(tmp),0,tmp)'
r.mapcalc 'tmp4 = if(isnull(tmp2),0,tmp2)'
r.mapcalc 'tmp5 = tmp3 + tmp4'
r.mapcalc 'sbwfire2_lag_nolag = if(tmp5==3,2,tmp5)'
r.mapcalc 'sbwfire2_nolag = if(sbwfire2_lag_nolag == 1,sbwfire2_lag_nolag,null())'
g.remove rast=tmp,tmp2,tmp3,tmp4,tmp5 
r.mapcalc 'tmp5_t = if(sbwfire2_lag_nolag==2,2,0) + if(isnull(sbwfire2_nolag),0,1)'
r.mapcalc 'sbwfire2_t = if(tmp5_t==0,null(),tmp5_t)'
g.remove rast=tmp5_t
r.to.vect --o input=sbwfire2_t output=sbwfire2_t feature=point
echo "ALTER TABLE sbwfire2_t ADD COLUMN sbwfreq integer" |db.execute
v.what.vect vect=sbwfire2_t qvector=sbw4105_freq column=sbwfreq qcolumn=freqdef
echo "ALTER TABLE sbwfire2_t ADD COLUMN cmi_ave float" |db.execute
v.what.rast vect=sbwfire2_t rast=cmi_ave col=cmi_ave
echo "ALTER TABLE sbwfire2_t ADD COLUMN FbSw float" |db.execute
v.what.rast vect=sbwfire2_t rast=FbSw col=fbsw
echo "ALTER TABLE sbwfire2_t ADD COLUMN FbSwSb float" |db.execute
v.what.rast vect=sbwfire2_t rast=FbSwSb col=fbswsb
echo "ALTER TABLE sbwfire2_t ADD COLUMN HW float" |db.execute
v.what.rast vect=sbwfire2_t rast=HW col=hw
}

Resampling_random_points_2() {
# execute the first part of Analysis_2
Analysis_2_1
# resample the random points in the seconf part of Analysis_1
for ((i=1 ; i <=50 ; i++))
do
    Analysis_2_2
    g.remove vect=sbwfire2b_"$i"_rand
    g.copy vect=sbwfire2_rand,sbwfire2b_"$i"_rand
done

# Save the different layers in resampling directory
# for ((i=1 ; i <=50 ; i++))
# do
#     v.out.ogr input=sbwfire1b_"$i"_rand type=point dsn=/home/jn/Canada/FireSBW/Analyses_Dec06/resampling olayer=sbwfire1b_"$i"_rand format=ESRI_Shapefile
# done

}


#####################################
## R Analysis
#####################################

Resampling_2_R() {
library(rpart)
channellibrary(maptree)
library(fields)
library(RODBC)
channel <- odbcConnect("grassdb","jn","budworm1",case="postgresql")

autoprune <- function(tree) {
    xerr <- tree$cptable[,"xerror"]
    cpmin.id <- which.min(xerr)
    
    xstd <- tree$cptable[,"xstd"]
    errt <- xerr[cpmin.id] + xstd[cpmin.id]
    cpSE1.min <- which.min(errt < xerr)
    mycp <- (tree$cptable[,"CP"])[cpSE1.min]
    
    return(mycp)
}

pdf(file="test50_2.pdf")

for(i in 1:50) {
	sbwfire2_rand <- sqlFetch(channel,paste("sbwfire2b_",i,"_rand",sep=""))
	sbwfire2.rpart <- rpart(value~.,data=sbwfire2_rand[,c("value","sbwfreq","cmi_ave","fbsw","fbswsb","hw")],method="class",cp=0)
	sbwfire2.rpart.p <- prune(sbwfire2.rpart,cp=autoprune(sbwfire2.rpart))
        sbwfire2.rpart.p$splits[,"index"] <-  round(sbwfire2.rpart.p$splits[,"index"],digits=1)
        draw.tree(sbwfire2.rpart.p,nodeinfo=T,pch=16,units="interaction",cases="cells",cex=.8)
}

dev.off()

}


Classification_tree_2_R() {
library(rpart)
library(maptree)
library(fields)
library(RODBC)
channel <- odbcConnect("grassdb","jn","budworm1",case="postgresql")
# Note: the results of a single regression tree can change from one run to the next (see below about unstable trees)
# To avoid having to change the description of the RT every time, we use always the same tree
# From the result of the resampling above, we selected the "best looking" tree (good classification rate without being
# too complex). The tree built on iteration #17 looked the best. We also set the seed to avoid variations of the pruning
# process from run to run.
# All the layers from the resampling (including #17 used hereafter) are saved in the resampling directory in shapefile format

sbwfire2_rand <- sqlFetch(channel,"sbwfire2b_1_rand")

autoprune <- function(tree) {
    xerr <- tree$cptable[,"xerror"]
    cpmin.id <- which.min(xerr)
    
    xstd <- tree$cptable[,"xstd"]
    errt <- xerr[cpmin.id] + xstd[cpmin.id]
    cpSE1.min <- which.min(errt < xerr)
    mycp <- (tree$cptable[,"CP"])[cpSE1.min]
    
    return(mycp)
}

sbwfire2.rpart <- rpart(value~.,data=sbwfire2_rand[,c("value","sbwfreq","cmi_ave","fbsw","fbswsb","hw")],method="class",cp=0)
sbwfire2.rpart.p <- prune(sbwfire2.rpart,cp=autoprune(sbwfire2.rpart))

# Reduce the number of digits to 1
sbwfire2.rpart.p$splits[,"index"] <-  round(sbwfire2.rpart.p$splits[,"index"],digits=1)

pdf("Figure19.pdf", paper="letter")
library(maptree)
draw.tree.jn(sbwfire2.rpart.p,nodeinfo=T,col=tim.colors(10),pch=16,units="interaction",cases="cells",cex=.7)
dev.off()

# Plot tree leaves on a map
## Create the map of different splits
system("r.mapcalc 'tree2 = if(cmi_ave > 53.1,100,0)'")
system("r.mapcalc 'tree2 = if(tree2 == 100 && cmi_ave >= 60,8,tree2)'")
system("r.mapcalc 'tree2 = if(tree2 == 100 && sbwfreq <= 7.5,9,tree2)'")
system("r.mapcalc 'tree2 = if(tree2 == 100 && sbwfreq > 7.5,10,tree2)'")
system("r.mapcalc 'tree2 = if(tree2 == 0 && FbSw > 30.4,7,tree2)'")
system("r.mapcalc 'tree2 = if(tree2 == 0 && cmi_ave <= 33,1,tree2)'")
system("r.mapcalc 'tree2 = if(tree2 == 0 && cmi_ave <= 42.6,200,tree2)'")
system("r.mapcalc 'tree2 = if(tree2 == 200 && HW > 53.9,5,tree2)'")
system("r.mapcalc 'tree2 = if(tree2 == 200 && HW <= 53.9,6,tree2)'")
system("r.mapcalc 'tree2 = if(tree2 == 0 && cmi_ave <= 44,2,tree2)'")
system("r.mapcalc 'tree2 = if(tree2 == 0 && cmi_ave > 44,300,tree2)'")
system("r.mapcalc 'tree2 = if(tree2 == 300 && cmi_ave >= 45.1,3,tree2)'")
system("r.mapcalc 'tree2 = if(tree2 == 300 && cmi_ave < 45.1,4,tree2)'")


## Plot
pdf("Figure20.pdf", paper="letter")
library(spgrass6)
G <- gmeta6()
if (!exists("ontario")) {
ontario <- readVECT6("ontario@basemaps")
}
tree.map <- readRAST6("tree2")
image(tree.map,col=tim.colors(6))
plot(ontario,add=T,lwd=1.5)
x.legend <- expression(1,2,3,bold(4),5,bold(6),bold(7),8,9,bold(10))
legend("bottomleft",legend=x.legend,fill=tim.colors(10),title="Leaves number",cex=0.7)
dev.off()

# Areas with lag and no lag (simplication of map above)
system(r.mapcalc 'tree2b = if(tree2 == 4 || tree2 == 6 || tree2 == 7 || tree2 == 10, 2, 1')

pdf("Figure21.pdf", paper="letter")
library(spgrass6)
G <- gmeta6()
if (!exists("ontario")) {
ontario <- readVECT6("ontario@basemaps")
}
tree.map <- readRAST6("tree2b")
image(tree.map,col=c("blue","red"))
plot(ontario,add=T,lwd=1.5)
legend("bottomleft",legend=c("no interaction","interaction"),fill=c("blue","red"))
dev.off()

# RandomForest
library(randomForest)
sbwfire2.rf <- randomForest(factor(value)~.,data=sbwfire2_rand[,c("value","sbwfreq","cmi_ave","fbsw","fbswsb","hw")],na.action=na.omit,importance=T)
pdf("Figure22.pdf",paper="letter")
varImpPlot(sbwfire2.rf,type=1,main="Importance according to mean decrease accuracy")
dev.off()

sbwfire2_t <- sqlFetch(channel,"sbwfire2_t")
sbwfire2.pred <- predict(sbwfire2.rf,sbwfire2_t)

}

##################################################################################################
# Analysis of sbw fire interaction #3
#
# In this analysis, we characterize the occurence of fire during the lag period as a function of:
#   -outbreak duration
#   -climate moisture index
#   -forest composition
#   -total frequency of defoliation
#   -defoliation zone
###################################################################################################

Analysis_3() {

# Create mask for sampling: take one raster from each type and add them all. This way
# we are sure that we will not have missing data at the end
v.to.rast --o input=sbw4105_freq output=sbwfreq use=attr column=freqdef
r.mapcalc "mask1=mint1+cmi_ave+FbSw+sbwfreq"
r.mask -o input=mask1

### Need to extract areas with lag > 1 in new coverage then apply
### v.to.rast to get the most accurate result (otherwise v.to.rast seems to behave
### stangely). The category value of the polygon is saved in the raster to allow for
### us to retrieve other attributes later
v.extract --o input=sbwfire1 type=area output=sbwfire3_lag where="lag > 0"
v.to.rast --o input=sbwfire3_lag output=tmp use=cat

### Extract areas inside the budworm belt (defzone > 0) then convert to raster, all the cells
### are coded with 0 so when adding the cells coded 1 for the fire-lag, we have the binary dataset
v.extract --o input=sbwfire1 type=area output=sbwfire3_nolag where="lag < 1"
v.to.rast --o input=sbwfire3_nolag output=tmp2 use=cat

### Overlay the 2 rasters but we favour the raster with lags so if a cell is lag and nolag,
### we choose to keep it with lags
### At 10km there are 3419 cells with no lag and 450 cells with lag
r.mapcalc 'sbwfire3_lag_nolag = if(isnull(tmp),0,tmp) + if(isnull(tmp),tmp2,0)'

# Transform to points. The category of each 
r.to.vect --o input=sbwfire3_lag_nolag output=sbwfire3_lag_nolag feature=point

# Transfer attributes from sbwfire1 to new point data
db.copy from_table=sbwfire1 to_table=a
echo "ALTER TABLE a RENAME COLUMN CAT TO CATA"|db.execute
echo "SELECT * INTO testx FROM a, sbwfire3_lag_nolag WHERE a.cata = sbwfire3_lag_nolag.value"|db.select
echo "ALTER TABLE testx DROP COLUMN cata"|db.execute
echo "ALTER TABLE testx DROP COLUMN label"|db.execute
echo "ALTER TABLE testx DROP COLUMN value"|db.execute
echo "DROP TABLE sbwfire3_lag_nolag"|db.execute
echo "ALTER TABLE testx RENAME TO sbwfire3_lag_nolag"|db.execute
echo "DROP TABLE a"|db.execute

# Import CMI
echo "ALTER TABLE sbwfire3_lag_nolag ADD COLUMN cmi_ave float" |db.execute
v.what.rast vect=sbwfire3_lag_nolag rast=cmi_ave col=cmi_ave
v.extract --o input=sbwfire3_lag_nolag type=point output=tmp3_3_pnts where="cmi_ave IS NOT NULL"
g.remove vect=sbwfire3_lag_nolag

# Import FRI data
echo "ALTER TABLE tmp3_3_pnts ADD COLUMN FbSw float" |db.execute
v.what.rast vect=tmp3_3_pnts rast=FbSw col=fbsw
v.extract --o input=tmp3_3_pnts type=point output=tmp3_4_pnts where="fbsw IS NOT NULL"
g.remove vect=tmp3_3_pnts
echo "ALTER TABLE tmp3_4_pnts ADD COLUMN FbSwSb float" |db.execute
v.what.rast vect=tmp3_4_pnts rast=FbSwSb col=fbswsb
v.extract --o input=tmp3_4_pnts type=point output=tmp3_5_pnts where="fbswsb IS NOT NULL"
g.remove vect=tmp3_4_pnts
echo "ALTER TABLE tmp3_5_pnts ADD COLUMN HW float" |db.execute
v.what.rast vect=tmp3_5_pnts rast=HW col=hw
v.extract --o input=tmp3_5_pnts type=point output=tmp3_6_pnts where="hw IS NOT NULL"
g.remove vect=tmp3_5_pnts

echo "select * from tmp3_6_pnts"|db.select|sed -e "s/|/,/g" > sbwfire3.txt

ExtractFile \#cCOMPUTE_LAG_BEGIN \#COMPUTE_LAG_END ComputeLag_3.f
# c      COMPUTE_LAG_BEGIN
# c      ComputeLag_3.f
# c       This program reads the records of sbw and fire from 1941 to 2005
# c      and checks if there is a lag or not
#  
#         PROGRAM ComputeLag_3 
#         CHARACTER*8 A(139) 
#         INTEGER CAT,SBW(65),FIRE(65),LAG,LAGWIND(3)
#         INTEGER LAGBOUND(3:5,2),DEFZONE,SBWFREQ,OBD
#         REAL*8 AREA,CMI,FBSW,FBSWSB,HW
#         DATA LAGBOUND(3,1),LAGBOUND(3,2)/3,6/
#         DATA LAGBOUND(4,1),LAGBOUND(4,2)/6,16/
#         DATA LAGBOUND(5,1),LAGBOUND(5,2)/4,9/
#         OPEN(UNIT=1, FILE='sbwfire3.txt', STATUS='OLD') 
#         OPEN(UNIT=2, FILE='sbwfire3lag.txt') 
# c        OPEN(UNIT=1, FILE='test.txt', STATUS='OLD') 
# c        OPEN(UNIT=2, FILE='testlag.txt') 
#  
# c Take care of the header
#        READ(UNIT=1,FMT=*) (A(I), I=1,138)
#        WRITE(2,98) (A(I), I=1,138),"SBWFREQ","OBD"
# 
#        OBD = 0
# 
# c Loop over the rows (3869 rows in sbwfire3.txt) 
#        DO 5 I=1,3869
# c        DO 5 I=1,1
#           READ(1,*) (SBW(J), J=1,65),DEFZONE,(FIRE(K), K=1,65),
#      c     AREA,LAG,CAT,CMI,FBSW,FBSWSB,HW
#           SBWFREQ=0
#           DO 10 N=1,65
#             SBWFREQ = SBWFREQ + SBW(N)
#  10       CONTINUE
#           IF (DEFZONE.GE.3.AND.DEFZONE.LE.5) THEN
#              JMAX = 65-LAGBOUND(DEFZONE,1)+1
#              DO 20 J=1,JMAX
#                IF (SBW(J).EQ.1) THEN
#                     IF (OBD.GT.0) THEN
#                         OBD = OBD + 1
#                     ELSE
#                         OBD = 1
#                     ENDIF
#                ELSE
#                     IF (OBD.GT.0) THEN
#                        IF (OBD.GE.4) THEN
#                            KMAX = MIN(65-J+1,LAGBOUND(DEFZONE,2))
#                             LAG = 0
#                             DO 30 K=LAGBOUND(DEFZONE,1),KMAX
#                                 IF (FIRE(J+K-1).EQ.1) THEN
#                                     LAG = 1
#                                     FIRE(J+K-1) = 0
#                                 ENDIF
#   30                        CONTINUE
#                             write(2,99) (SBW(L), L=1,65),DEFZONE,
#      c                         (FIRE(M), M=1,65),AREA,LAG,CAT,CMI,
#      c                         FBSW,FBSWSB,HW,SBWFREQ,OBD
#                         ENDIF
#                        OBD = 0
#                     ENDIF
#                ENDIF
#   20         CONTINUE
#           ENDIF
#    5    CONTINUE
#  
#   97       FORMAT(I6,',',I1)
#   98       FORMAT(138(A8,','),A8,',',A8)
#   99       FORMAT(65(I1,','),I3,',',65(I1,','),F13.6,',',I2,
#      c        ',',I6,4(',',F13.6),2(',',I2))
#         END 

g77 -O -o ComputeLag_3 ComputeLag_3.f

# Run ComputeLag_3
./ComputeLag_3

cat sbwfire3lag.txt | sed "s/ //g" > a
mv a sbwfire3lag.txt

# Remove all the rows from sbwfire1
echo "DELETE FROM tmp3_6_pnts"|db.execute

# Fill up again with new data
# Needs to move the file to /tmp because user postgres cannot access my directories
tail -n 4687 sbwfire3lag.txt > /tmp/a
echo "ALTER TABLE tmp3_6_pnts ADD COLUMN SBWFREQ INTEGER"|db.execute
echo "ALTER TABLE tmp3_6_pnts ADD COLUMN OBD INTEGER"|db.execute
echo "COPY tmp3_6_pnts FROM '/tmp/a' USING DELIMITERS ','"|db.execute

}

#####################################
## R Analysis
#####################################

sbwfire3lag <- read.table("sbwfire3lag.txt",header=T,sep=",")

# Histogram of OBD for fire and no fire inside a SFIP
a <- table(sbwfire3lag$OBD[sbwfire3lag$lag == 0])/sum(table(sbwfire3lag$OBD[sbwfire3lag$lag == 0]))
b <- table(sbwfire3lag$OBD[sbwfire3lag$lag > 0])/sum(table(sbwfire3lag$OBD[sbwfire3lag$lag > 0]))
pdf(file="Figure23.pdf",paper="letter")
par(mfrow=c(1,2))
barplot(a,space=0,col="blue",ylim=c(0,0.5),xlab="OBD",main="No fire",ylab="Frequency")
barplot(b,space=0,col="red",ylim=c(0,0.5),xlab="OBD",main="Fire",ylab="Frequency")
dev.off()

# Chi-square to compare distributions
a <- table(sbwfire3lag$OBD[sbwfire3lag$lag == 0])
b <- table(sbwfire3lag$OBD[sbwfire3lag$lag > 0])
chisq.test(as.matrix(data.frame(as.vector(a),as.vector(b))),simulate.p.value=T)

# Build balanced dataset by sampling same number of negative SFIPs than positive ones
NPos <- length(sbwfire3lag$OBD[sbwfire3lag$lag > 0])
a <- sbwfire3lag[sbwfire3lag$lag == 0,]
b <- sbwfire3lag[sbwfire3lag$lag > 0,]
a_rand <- a[sample(1:dim(a)[1],size=NPos),]
sbwfire3lag_rand <- rbind(a_rand,b)

# Draw 50 classification trees
library(rpart)
library(maptree)
library(fields)
autoprune <- function(tree) {
    xerr <- tree$cptable[,"xerror"]
    cpmin.id <- which.min(xerr)
    
    xstd <- tree$cptable[,"xstd"]
    errt <- xerr[cpmin.id] + xstd[cpmin.id]
    cpSE1.min <- which.min(errt < xerr)
    mycp <- (tree$cptable[,"CP"])[cpSE1.min]
    
    return(mycp)
}

for (i in 1:50) {
a_rand <- a[sample(1:dim(a)[1],size=NPos),]
assign(paste("a_rand_",i,sep=""),a_rand)
}

pdf("Test50_3.pdf", paper="letter")
for (i in 1:50) {
set.seed(400)
a_rand <- get(paste("a_rand_",i,sep=""))
sbwfire3lag_rand <- rbind(a_rand,b)
sbwfire3.rpart <- rpart(lag~.,data=sbwfire3lag_rand[,c("lag","SBWFREQ","cmi_ave","fbsw","fbswsb","hw","OBD")],method="class",cp=0)
sbwfire3.rpart.p <- prune(sbwfire3.rpart,cp=autoprune(sbwfire3.rpart))
# Reduce the number of digits to 1
sbwfire3.rpart.p$splits[,"index"] <-  round(sbwfire3.rpart.p$splits[,"index"],digits=1)
library(maptree)
draw.tree(sbwfire3.rpart.p,nodeinfo=T,col=tim.colors(10),pch=16,units="interaction",cases="cells",cex=.7)
}
dev.off()

# write.table(a_rand_35,file="a_rand_35.txt")

# We select #31 with 8 terminal leaves and a classification rate of 78.4%
a_rand <- read.table(file="a_rand_35.txt")
set.seed(400)
sbwfire3lag_rand <- rbind(a_rand,b)
sbwfire3.rpart <- rpart(lag~.,data=sbwfire3lag_rand[,c("lag","SBWFREQ","cmi_ave","fbsw","fbswsb","hw","OBD")],method="class",cp=0)
sbwfire3.rpart.p <- prune(sbwfire3.rpart,cp=autoprune(sbwfire3.rpart))
# Reduce the number of digits to 1
sbwfire3.rpart.p$splits[,"index"] <-  round(sbwfire3.rpart.p$splits[,"index"],digits=1)
pdf("Figure24.pdf", paper="letter")
library(maptree)
draw.tree(sbwfire3.rpart.p,nodeinfo=T,col=tim.colors(9),pch=16,units="interaction",cases="cells",cex=.7)
dev.off()

# RandomForest
library(randomForest)
sbwfire3.rf <- randomForest(factor(lag)~.,data=sbwfire3lag_rand[,c("lag","SBWFREQ","cmi_ave","fbsw","fbswsb","hw","OBD")],na.action=na.omit,importance=T)
pdf("Figure25.pdf",paper="letter")
varImpPlot(sbwfire3.rf,type=1,main="Importance according to mean decrease accuracy")
dev.off()

# Bootstrap of RandomForests
randomForest_rank <- NA
for(i in 1:50) {
    a_rand <- get(paste("a_rand_",i,sep=""))
    b <- table(sbwfire3lag$OBD[sbwfire3lag$lag > 0])/sum(table(sbwfire3lag$OBD[sbwfire3lag$lag > 0]))
    sbwfire3lag_rand <- rbind(a_rand,b)
    sbwfire3.rf <- randomForest(factor(lag)~.,data=sbwfire3lag_rand[,c("lag","SBWFREQ","cmi_ave","fbsw","fbswsb","hw","OBD")],na.action=na.omit,importance=T)
    a <- 7-rank(sbwfire3.rf$importance[,3])
    randomForest_rank <- c(randomForest_rank,a)	
}

pdf("Figure26.pdf",paper="letter")
par(mfrow=c(3,3))
a <- tapply(randomForest_rank,names(randomForest_rank),function(x) table(x))
barplot(a$cmi_ave,xlab="cmi_ave",ylab="Frequency")
barplot(a$fbsw,xlab="fbsw",ylab="Frequency")
barplot(a$fbswsb,xlab="fbswsb",ylab="Frequency")
barplot(a$hw,xlab="hw",ylab="Frequency")
barplot(a$SBWFREQ,xlab="SBWFREQ",ylab="Frequency")
barplot(a$OBD,xlab="OBD",ylab="Frequency")
dev.off()

# Conditional classification tree
library(party)
sbwfire3.ctree <- ctree(factor(lag)~.,data=sbwfire3lag_rand[,c("lag","SBWFREQ","cmi_ave","fbsw","fbswsb","hw","OBD")])
plot(sbwfire3.ctree)

}

draw.tree.jn <- 
function (tree, cex = par("cex"), pch = par("pch"), size = 2.5 * 
    cex, col = NULL, nodeinfo = FALSE, units = "", cases = "obs", 
    digits = getOption("digits"), print.levels = TRUE, new = TRUE) 
{
    if (new) 
        plot.new()
    rtree <- length(attr(tree, "ylevels")) == 0
    tframe <- tree$frame
    rptree <- length(tframe$complexity) > 0
    node <- as.numeric(row.names(tframe))
    depth <- floor(log(node, base = 2) + 1e-07)
    depth <- as.vector(depth - min(depth))
    maxdepth <- max(depth)
    x <- -depth
    y <- x
    leaves <- tframe$var == "<leaf>"
    x[leaves] <- seq(sum(leaves))
    depth <- split(seq(node)[!leaves], depth[!leaves])
    parent <- match(node%/%2, node)
    left.child <- match(node * 2, node)
    right.child <- match(node * 2 + 1, node)
    for (i in rev(depth)) x[i] <- 0.5 * (x[left.child[i]] + x[right.child[i]])
    nleaves <- sum(leaves)
    nnodes <- length(node)
    nodeindex <- which(tframe$var != "<leaf>")
    if (rtree) {
        dev <- tframe$dev
        pcor <- rep(0, nnodes)
        for (i in 1:nnodes) if (!leaves[i]) {
            l <- dev[node == (node[i] * 2)]
            r <- dev[node == (node[i] * 2 + 1)]
            pcor[i] <- dev[i] - l - r
        }
        pcor <- round(pcor/dev[1], 3) * 100
    }
    else {
        crate <- rep(0, nnodes)
        trate <- 0
        if (!rptree) {
            for (i in 1:nnodes) {
                yval <- tframe$yval[i]
                string <- paste("tframe$yprob[,\"", as.character(yval), 
                  "\"]", sep = "")
                crate[i] <- eval(parse(text = string))[i]
                if (leaves[i]) 
                  trate <- trate + tframe$n[i] * crate[i]
            }
        }
        else {
            for (i in 1:nnodes) {
                yval <- tframe$yval[i]
                nlv <- floor(ncol(tframe$yval2)/2)
                index <- rev(order(tframe$yval2[i, 2:(nlv + 1)]))[1]
                crate[i] <- tframe$yval2[i, (nlv + 1 + index)]
                if (leaves[i]) 
                  trate <- trate + tframe$n[i] * crate[i]
            }
        }
        crate <- round(crate, 3) * 100
        trate <- round(trate/tframe$n[1], 3) * 100
    }
    if (is.null(col)) 
        kol <- rainbow(nleaves)
    else kol <- col
    xmax <- max(x)
    xmin <- min(x)
    ymax <- max(y)
    ymin <- min(y)
    pinx <- par("pin")[1]
    piny <- par("pin")[2]
    xscale <- (xmax - xmin)/pinx
    box <- size * par("cin")[1]
    if (box == 0) 
        xbh <- xscale * 0.2
    else xbh <- xscale * box/2
    chr <- cex * par("cin")[2]
    tail <- box + chr
    yscale <- (ymax - ymin)/(piny - tail)
    ytail <- yscale * tail
    if (box == 0) 
        ybx <- yscale * 0.2
    else ybx <- yscale * box
    ychr <- yscale * chr
    ymin <- ymin - ytail
    xf <- 0.1 * (xmax - xmin)
    yf <- 0.1 * (ymax - ymin)
    x1 <- xmin - xf
    x2 <- xmax + xf
    y1 <- ymin - yf
    y2 <- ymax + yf
    par(usr = c(x1, x2, y1, y2))
    v <- as.character(tframe$var[1])
    if (rptree) {
        sp <- tree$splits[1, ]
        val <- sp["index"]
        if (sp["ncat"] > 1) {
            r <- sp["index"]
            string <- "attributes(tree)$xlevels$"
            string <- paste(string, v, sep = "")
            xl <- eval(parse(text = string))
            lf <- rf <- ""
            for (k in 1:sp["ncat"]) if (tree$csplit[r, k] == 
                1) 
                lf <- paste(lf, xl[k], sep = ",")
            else rf <- paste(rf, xl[k], sep = ",")
            if (!print.levels) 
                string <- v
            else string <- paste(lf, "=", v, "=", rf)
        }
        else {
            if (sp["ncat"] < 0) 
                op <- "<>"
            else op <- "><"
            string <- paste(v, op, val)
        }
    }
    else {
        val <- substring(as.character(tframe$splits[1, 1]), 2)
        string <- paste(as.character(v), "<>", val)
    }
    text.default(x[1], y[1], string, cex = cex)
    if (nodeinfo) {
        n <- tframe$n[1]
        if (rtree) {
            z <- round(tframe$yval[1], digits)
            r <- pcor[1]
            string <- paste(z, " ", units, "; ", n, " ", cases, 
                "; ", r, "%", sep = "")
        }
        else {
            z <- attr(tree, "ylevels")[tframe$yval[1]]
            r <- crate[1]
            string <- paste(z, "; ", n, " ", cases, "; ", r, 
                "%", sep = "")
        }
        text.default(x[1], y[1] - ychr, string, cex = cex)
    }
    for (i in 2:nnodes) {
        ytop <- ychr * (as.integer(nodeinfo) + 1)
        if (y[i] < y[i - 1]) {
            lines(c(x[i - 1], x[i]), c(y[i - 1] - ytop, y[i - 
                1] - ytop))
            lines(c(x[i], x[i]), c(y[i - 1] - ytop, y[i] + ychr))
        }
        else {
            lines(c(x[parent[i]], x[i]), c(y[parent[i]] - ytop, 
                y[parent[i]] - ytop))
            lines(c(x[i], x[i]), c(y[parent[i]] - ytop, y[i] + 
                ychr))
        }
        if (!leaves[i]) {
            v <- as.character(tframe$var[i])
            if (rptree) {
                if (length(tree$ordered) > 1) {
                  k <- 1
                  for (j in 1:(i - 1)) {
                    m <- tframe$ncompete[j]
                    if (m > 0) 
                      k <- k + m + 1
                    m <- tframe$nsurrogate[j]
                    if (m > 0) 
                      k <- k + m
                  }
                }
                else k <- match(i, nodeindex[-1]) + 1
                sp <- tree$splits[k, ]
                val <- sp["index"]
                if (sp["ncat"] > 1) {
                  r <- sp["index"]
                  string <- "attributes(tree)$xlevels$"
                  string <- paste(string, v, sep = "")
                  xl <- eval(parse(text = string))
                  lf <- rf <- ""
                  for (k in 1:sp["ncat"]) if (tree$csplit[r, 
                    k] == 1) 
                    lf <- paste(lf, xl[k], sep = ",")
                  else rf <- paste(rf, xl[k], sep = ",")
                  if (!print.levels) 
                    string <- v
                  else string <- paste(lf, "=", v, "=", rf)
                }
                else {
                  if (sp["ncat"] < 0) 
                    op <- "<>"
                  else op <- "><"
                  string <- paste(v, op, val)
                }
            }
            else {
                val <- substring(as.character(tframe$splits[i, 
                  1]), 2)
                string <- paste(as.character(v), "<>", val)
            }
            text.default(x[i], y[i], string, cex = cex)
            if (nodeinfo) {
                n <- tframe$n[i]
                if (rtree) {
                  z <- round(tframe$yval[i], digits)
                  r <- pcor[i]
                  string <- paste(z, " ", units, "; ", n, " ", 
                    cases, "; ", r, "%", sep = "")
                }
                else {
                  z <- attr(tree, "ylevels")[tframe$yval[i]]
                  r <- crate[i]
                  string <- paste(z, "; ", n, " ", cases, "; ", 
                    r, "%", sep = "")
                }
                text.default(x[i], y[i] - ychr, string, cex = cex)
            }
        }
        else {
            if (box == 0) {
                lines(c(x[i], x[i]), c(y[i], y[i] + ychr))
                lines(c(x[i] - xbh, x[i] + xbh), c(y[i], y[i]))
            }
            else {
                points(x[i], y[i], pch = pch, cex = size, col = kol[x[i]])
            }
            if (rtree) {
                z <- round(tframe$yval[i], digits)
                text.default(x[i], y[i] - ybx, paste(z, units, 
                  sep = " "), cex = cex)
            }
            else {
                z <- attr(tree, "ylevels")[tframe$yval[i]]
                text.default(x[i], y[i] - ybx, z, cex = cex)
            }
            n <- tframe$n[i]
            n0 <- tree$frame$yval2[i,2]
            n1 <- tree$frame$yval2[i,3]
            text.default(x[i], y[i] - ybx - ychr, paste(n,cases, 
                sep = " "), cex = cex)
            text.default(x[i], y[i] - 1.5*ybx - 1.5*ychr, paste("(",n0,"/",n1,")",
                sep = ""), cex = cex)
            if (box != 0) 
                text.default(x[i], y[i], as.character(x[i]), 
                  cex = cex)
        }
    }
    if (nodeinfo) {
        if (rtree) 
            string <- paste("Total deviance explained =", sum(pcor), 
                "%")
        else string <- paste("Total classified correct =", trate, 
            "%")
        if (box == 0) 
            mtext(string, side=1, cex = 1.3 * cex)
        else mtext(string, side=1, cex = 1.3 * cex)
    }
}
draw.tree.jn(sbwfire3.rpart.p,nodeinfo=T,col=tim.colors(9),pch=16,units="interaction",cases="cells",cex=.7)



for (i in 1:50) {
  sbwfire2_rand <- dbReadTable(con,paste("sbwfire1c_",i,"_rand",sep=""))
  sbwfire2.rpart <- rpart(value~.,data=sbwfire2_rand[,c("value","sbwfreq","cmi_ave","fbsw","fbswsb","hw","pines","sb")],method="class",cp=0)
  sbwfire2.rpart.p <- prune(sbwfire2.rpart,cp=autoprune(sbwfire2.rpart))
  sbwfire2.rpart.p$splits[,"index"] <-  round(sbwfire2.rpart.p$splits[,"index"],digits=1)
  draw.tree.jn(sbwfire2.rpart.p,nodeinfo=T,col=tim.colors(6),pch=16,units="interaction",cases="cells",cex=.8)
}

sbwfire1.rpart <- rpart(value~.,data=sbwfire1_rand[,c("value","sbwfreq","cmi_ave","fbsw","fbswsb","hw")],method="class",cp=0,parms=list(prior=c(0.,0.5)))
sbwfire1.rpart.p <- prune(sbwfire1.rpart,cp=0.020)
sbwfire1.rpart.p$splits[,"index"] <-  round(sbwfire1.rpart.p$splits[,"index"],digits=1)
draw.tree.jn(sbwfire1.rpart.p,nodeinfo=T,col=tim.colors(6),pch=16,units="interaction",cases="cells",cex=.8)

pdf("test4.pdf",paper="USr")
for (i in 1:50) {
  sbwfire2_rand <- dbReadTable(con,paste("sbwfire1c_",i,"_rand",sep=""))
  sbwfire2.ctree <- ctree(value~.,data=sbwfire2_rand[,c("value","sbwfreq","cmi_ave","fbsw","fbswsb","hw","pines","sb")])
  plot(sbwfire2.ctree)
}
dev.off()



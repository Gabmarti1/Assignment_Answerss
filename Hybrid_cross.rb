#we create anew class called Hybrid_ cross and we define the attributes
class Hybrid_cross
    attr_accessor :parent1
    attr_accessor :parent2
    attr_accessor :f2_wild
    attr_accessor :f2_p1
    attr_accessor :f2_p2
    attr_accessor :f2_p1p2
    attr_accessor :chi_dist
    
    def initialize (params = {})
        @parent1 = params.fetch(:parent1, '')
        @parent2 = params.fetch(:parent2, '')
        @f2_wild = params.fetch(:f2_wild, '')
        @f2_p1 = params.fetch(:f2_p1, '')
        @f2_p2 = params.fetch(:f2_p2, '')
        @f2_p1p2 = params.fetch(:f2_p1p2, '')
        @chi_dist = params.fetch(:chi_dist, '7.815')
        @chi_dist = @chi_dist.to_f
    end
    #we make a function in order to calculate total and esperates values
    def linkage 
        total = @f2_wild + @f2_p1 + @f2_p2 + @f2_p1p2
        e_wild = total * (9/16.to_f)
        e_p1 = total *(3/16.to_f)
        e_p2 = total *(3/16.to_f)
        e_het = total *(1/16.to_f)
        return total,e_wild,e_p1,e_p2,e_het
    end
    #we make this funcction in order to calculate the chi-square value
    def calculate (total,e_wild,e_p1,e_p2,e_het)

        xsq = ((@f2_wild-e_wild)**2/e_wild) + ((@f2_p1-e_p1)**2/e_p1)+ ((@f2_p2-e_p2)**2/e_p2) + ((@f2_p1p2-e_het)**2/e_het)
        #if the chi-square value is higher than the chi-distance, the genes are ligated
        if xsq > @chi_dist
            $stderr.puts "The genes contained in the stock #{parent1} and #{parent2} are linked with a score of #{xsq}"
        end
    end
end

#taking in account that we consider a pvalue of 0.05  and we have three degrees of freedom (because is number of variables -1)-1=3 
#degrees of freedom = 3 and a pvalue = 0.05 the limit value to say if are linkaged or not is 7.815
# we call stringio in order to make the function IO.foreach
require 'stringio'
    # we create a new array
    arr2 = Array.new([])
    n2 = 1
    #we run the file
    IO.foreach("C:/Users/gabig/Downloads/StockDatabaseDataFiles/cross_data.tsv", "\n"){
        |row|
        #we split the line by columns
        row =row.split("\t")
        #we avoid the header
        if n2 == 1 
            n2 = 0
        else 
            #we have to convert the string to float because later we have to operate
            p1 = row[0] 
            p2 = row[1]
            wild= row[2].to_f

            desc1 = row[3].to_f
            desc2 = row[4].to_f
            f2_cross= row[5].to_f
            #we create the objects of this class
            g2 = Hybrid_cross.new(:parent1 =>p1 ,:parent2 =>p2 ,:f2_wild => wild,:f2_p1 =>desc1 ,:f2_p2=> desc2, :f2_p1p2 => f2_cross)
            #we append the objects to the array
            arr2.append(g2)
        end
    }
#we call the function previously defines to calculate the chi-square test overlooping the array
arr2.each do |line|
    x,y,z,w,q = line.linkage
    line.calculate(x,y,z,w,q)
end

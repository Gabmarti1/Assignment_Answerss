#we create a new class called Gene
#we define the attributes
class Gene
    attr_accessor :gene_id
    attr_accessor :gene_name
    attr_accessor :mutant_phenotype
#we start the attributes. This method is atumatically run when an object is created 
    def initialize (params = {})
        @gene_id = params.fetch(:gene_id, 'somenumber')
        @gene_name = params.fetch(:gene_name, 'somegene')
        @mutant_phenotype = params.fetch(:mutant_phenotype, 'wild')
    end
    
    
end
#we add the objects to the new class 
require 'stringio'
        #we create an array to save the different objects 
        arr = Array.new([])
        n = 1
        #we open and run the file
        IO.foreach("C:/Users/gabig/Downloads/StockDatabaseDataFiles/gene_information.tsv", "\n"){
            |line|
            #we split the file by columns in order to get tha vaues of the different attributes
            line =line.split("\t")
            #we avoid the header line
            if n == 1 
                n = 0
            else 
                id = line[0] 
                name = line[1]
                phenotype= line[2]
                #we create the objects of the class with the values of the attributes from the columns of the file
                g =Gene.new(:gene_id => id,:gene_name => name,:mutant_phenotype => phenotype)
                #we append the objects to the array 
                arr.append(g)
            end
        }

    

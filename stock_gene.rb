require 'date'
#we start the class and define the attributes
class Gene_stock
    attr_accessor :seed_stock
    attr_accessor :mutant_gene_id
    attr_accessor :last_planted
    attr_accessor :storage
    attr_accessor :grams_remaining
    
    def initialize (params = {})
        @seed_stock = params.fetch(:seed_stock, '')
        @mutant_gene_id = params.fetch(:mutant_gene_id, '')
        @last_planted = params.fetch(:last_planted, '00/00/0000')
        @storage = params.fetch(:storage, '')
        @grams_remaining = params.fetch(:grams_remaining, '')
    end
    #we have to update the amount of seeds
    def change_seed_values(consume)
        #we rest the amount consumed
        @grams_remaining -= consume
        #we changed tha date bacause the aomunt is updated
        @last_planted = DateTime.now.strftime('%-d/%-m/%Y') # https://ruby-doc.org/stdlib-1.9.3/libdoc/date/rdoc/DateTime.html
        # from mark. 
        #we have to send and message for advertising that there is no more seeds
        # and if this amount is under 0 we have to assign the value 0 becaues we can't have a negative amount
        if @grams_remaining <= 0
            @grams_remaining = 0
            $stderr.puts "Warning, there is no more #{seed_stock} stock"
            
        end
    end

end

#we are going to introduce the values of the attributes in Gene_stock class
#we call stringio to fo IO.foreach method
require 'stringio'
#we create an array of objects wich contain the entrance of the class
    arr1 = Array.new([])
    n1 = 1
    header = ''
    IO.foreach("C:/Users/gabig/Downloads/StockDatabaseDataFiles/seed_stock_data.tsv" , "\n"){
        |lines|
        #we avoid the header line
        if n1 == 1 
            n1 = 0
            header = lines
        # now we split the file by columns  
        else 
            lines =lines.split("\t")
            seed = lines[0] 
            mutant_id = lines[1]
            last= lines[2]
            stor = lines[3]
            #we convert the string to float in order to make operations
            grams = lines[4].to_f
            #we create new entrances of the class
            g1 = Gene_stock.new(:seed_stock =>seed ,:mutant_gene_id =>mutant_id ,:last_planted => last,:storage =>stor ,:grams_remaining => grams.to_f)
            #we append the objects to the array
            arr1.append(g1)
        
        end
    }

##now we modified the values of the seed_remaining
arr1.each do |n|
    #here we call the function pre-defined in class method
    n.change_seed_values(7.0)
end
#we open a new file to generate the tsv file updated
out = File.new("seed_stock_data_updated.tsv","w")
#we add the header line
out.puts(header)

#looping the array of objects to add all the attributes in the newfile
arr1.each do |row|    
    out.puts(row.seed_stock + "\t" + row.mutant_gene_id + "\t" + row.last_planted + "\t" + row.storage + "\t" + row.grams_remaining.to_s + "\n")
end    
 




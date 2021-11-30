require 'bio'
require 'net/http'
filename = ARGV[0]
dict_genes = Hash.new

lista1=[]
lista2=[]
file=[]
File.open(filename).each do |line|
    file.append(line)
    address = URI("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{line}")
    result = Net::HTTP.get_response(address)

    next if result.nil?

    record = result.body

    next if record.nil?
    
    File.open("gen_sequences.embl",'w+') do |lines|
        lines.puts record
    end
    
    query_sequence_f="CTTCTT"
    query_sequence_r="AAGAAG"
    
    sequences = Bio::FlatFile.auto("gen_sequences.embl")
    sequences.each_entry do |record|
        puts 'a'
        next unless record.features.length != 0
        puts'b'
        sequence = record.to_biosequence
        record.features.each do |feature|
            next unless feature.feature == 'exon'
            feature.locations.each do |attributes|
                
                exon_seq = record.seq[attributes.from..attributes.to] 
                next if exon_seq.nil?
                if attributes.strand == 1 
                    
                    indexes=exon_seq.to_enum(:scan,/(?=cttctt)/).map{Regexp.last_match.begin(0)}
                    
                    
                    next if indexes.length ==0
                    
                    indexes.each do |num|
                        puts num
                        st_posit = attributes.from + num.to_i + 1
                        f_posit = st_posit + query_sequence_f.length - 1
                        coordenates = [st_posit,f_posit].join('..')
                        coord = Bio::Feature.new("motif_repetition",coordenates)
                        coord.append(Bio::Feature::Qualifier.new('repeat_motif', 'CTTCTT'))
                        coord.append(Bio::Feature::Qualifier.new('strand', '+'))
                        sequence.features << coord unless lista1.include?(st_posit)
                        lista1.append(st_posit)
                        dict_genes[line] = sequence
                        
                    end
                

                        
                        
                    

                elsif attributes.strand == -1
                    
                    indexes = exon_seq.to_enum(:scan,/(?=aagaag)/).map{Regexp.last_match.begin(0)}
                    
                    next if indexes.length == 0
                    indexes.each do |num|
                        puts num   
                        f_pos = num.to_i + 1 + attributes.from  
                        st_pos = f_pos + query_sequence_f.length - 1
                        coordenates = [st_pos,f_pos].join('..')
                        coord = Bio::Feature.new("motif_repetition",coordenates)
                        coord.append(Bio::Feature::Qualifier.new('repeat_motif', 'CTTCTT'))
                        coord.append(Bio::Feature::Qualifier.new('strand', '-'))
                        sequence.features << coord unless lista2.include?(st_pos)
                        lista2.append(st_pos)
                        dict_genes[line] = sequence
                        
                    end
                    
                
                    
                end
                

                
            
            end
        

            
        end
    end
    
end

File.open('genes_without_motif','w+') do |genes|
    file.each do |genes2|
        next if dict_genes.keys.include?(genes2) 
        genes.puts(genes2)
    end 
end  
File.open('genes_exon_features.gff3','w+') do |lines|
    lines.puts("###gff-version3")
    dict_genes.each do |code,bio_sequence|
        code = code.strip()
        
        n=0
        bio_sequence.features.each do |feature|
            
            
            next unless feature.feature=='motif_repetition'
            n += 1
            pos = feature.locations.first
            
            score='.'
            phase='.'
            source='ruby'
            strand = feature.assoc['strand']
            attributes = "ID=The_motif_CTTCTT_is _present_in_the_gene#{code}_#{n}appearance"
            lines.puts(code +"\t"+source+"\t"+"motif"+"\t"+ (pos.from.to_s) +"\t"+(pos.to.to_s)+"\t"+score+"\t"+strand+"\t"+phase+"\t"+attributes)
        end
    end
end   
File.open('chr_exon_features.gff3','w+') do |lines1|
    lines1.puts("##gff3_file")
    dict_genes.each do|name,bio_sequence|
        name=name.strip()
        coord_i_crom=bio_sequence.primary_accession.split(":")[3].to_i
        crom= bio_sequence.primary_accession.split(":")[2]
        n = 0
        bio_sequence.features.each do |feature|
            
            
            next unless feature.feature=='motif_repetition'
            n += 1
            pos = feature.locations.first
            pos_i= coord_i_crom + pos.from.to_i
            pos_f= coord_i_crom + pos.to.to_i
            score='.'
            phase='.'
            source='ruby'
            strand = feature.assoc['strand']
            attributes = "ID=The_motif_CTTCTT_is _present_in_the_gene#{name}_#{n}appearance"
            lines1.puts('chr'+crom +"\t"+source+"\t"+"motif"+"\t"+ (pos_i.to_s) +"\t"+(pos_f.to_s)+"\t"+score+"\t"+strand+"\t"+phase+"\t"+attributes)
        end
    end
end


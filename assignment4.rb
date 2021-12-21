require 'bio'
require 'stringio'
file1=ARGV[0]
file2=ARGV[1]
def biofile(file)
    files = Bio::FlatFile.auto(file)
    sequence = Bio::Sequence.auto(files.next_entry.seq).guess
    if sequence == Bio::Sequence::NA
        return 'nucl'
    else
        return 'prot'
    end
end
biofile(file1)
biofile(file2)
org1= Hash.new
org2= Hash.new

Bio::FlatFile.auto(file1).each_entry do |line|
    org1[line.entry_id] = line.seq
end


Bio::FlatFile.auto(file2).each_entry do |line|
    org2[line.entry_id] = line.seq


end



type1 = biofile(file1)
type2 = biofile(file2)
system("makeblastdb -in #{file1} -dbtype #{type1}")
system("makeblastd -in #{file2} -dbtype #{type2}")

e_value = '-e 10**-9'

if biofile(file1) == 'prot' && biofile(file2) == 'nucl'
    blast1 = Bio::Blast.local('blastx',"#{file1}", "F 'm S' #{e_value}")
    blast2 = Bio::Blast.local('tblastn',"#{file2}","F 'm S' #{e_value}")
elsif biofile(file1) == 'nucl' && biofile(file2) == 'prot'
    blast1 = Bio::Blast.local('tblastn',"#{file1}","F 'm S' #{e_value}")
    blast2 = Bio::Blast.local('blastx',"#{file2}","F 'm S' #{e_value}")
    
end

orthologues = Hash.new
org2.each do |key,values|

    hit = blast1.query(">query_seq\n#{values}")
    next unless hit.hits.length != 0
    id = hit.hits[0].definition.split("|")[0].strip
    reciprocal_hit = blast2.query(">query_seq\n#{org1[id]}")
    next unless reciprocal_hit.hits.length != 0
    rec_id = reciprocal_hit.hits[0].definition.split("|")[0].strip
    if rec_id==key
        orthologues[values]=id
    end
end
n = 0
File.open('orthologues_report.txt','w+') do |line|
    orthologues.each do |key,values|
        n += 1
        line.puts " #{key} -> #{values}"
    end
end
puts "we have found #{n} orthologues"
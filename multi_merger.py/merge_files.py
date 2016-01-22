import collections

def remove_common(names):
    start = names[0]
    end = names[0]
    for name in names:
        while len(start) > 0 and not(name.startswith(start)):
            start = start[:-1]
        while len(end) > 0 and not(name.endswith(end)):
            end = end[1:]
    new_names = []
    for name in names:
        new_name = name[len(start):-len(end)]
        new_names.append(new_name)
    return new_names    

def return_blank():
    return ""

def black_dict():
    return collections.defaultdict(return_blank)

def merge_files(file_paths, names_path, target_path):
    i = -1
    names=[]
    with open(names_path, 'r') as f:
        for line in f:
            names.append(line)
    new_names = remove_common(names)    print new_names
    all_values =  collections.defaultdict(black_dict)
    for count, file_path in enumerate(file_paths):        #print count, file_path
        with open(file_path, 'r') as f:
            for line in f:
                parts = line.strip().split("\t")
                if len(parts) == 2:
                    #print parts
                    all_values[parts[0]][new_names[count]] = parts[1]
                else: 
                    print "ignoring following line from", file_path
                    print line 
    with open(target_path, 'w') as f:
        for name in new_names:
            f.write("\t")
            f.write(name)
        f.write("\n")
        last = len(names)
        for key in all_values:
            f.write(key)
            for name in new_names:
                f.write("\t")
                f.write(all_values[key][name])
            f.write("\n")        

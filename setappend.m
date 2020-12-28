function set = setappend(set, element)

    if sum(element == set) == 0
        set = [set, element];
    end
end

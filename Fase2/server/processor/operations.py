# ---------------------- STRING INPUT ------------------------------
def stringify_data(data):
    data_size = len(data)
    styled_string = ""
    for n in range(data_size):
        styled_string += str(data[n])
        if(n < (data_size-1)):
            styled_string += "\n"
    styled_string += "$"
    return styled_string
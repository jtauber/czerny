def nw_align(a, b, replace_func, insert, delete):

    ZERO, LEFT, UP, DIAGONAL = 0, 1, 2, 3

    len_a, len_b = len(a), len(b)

    matrix = [[(0, ZERO) for x in range(len_b + 1)] for y in range(len_a + 1)]

    for i in range(len_a + 1):
        matrix[i][0] = (insert * i, UP)

    for j in range(len_b + 1):
        matrix[0][j] = (delete * j, LEFT)

    for i in range(1, len_a + 1):
        for j in range(1, len_b + 1):
            replace = replace_func(a[i - 1], b[j - 1])
            matrix[i][j] = max([
                (matrix[i - 1][j - 1][0] + replace, DIAGONAL),
                (matrix[i][j - 1][0] + insert, LEFT),
                (matrix[i - 1][j][0] + delete, UP)
            ])

    i, j = len_a, len_b
    alignment = []

    while (i, j) != (0, 0):
        if matrix[i][j][1] == DIAGONAL:
            alignment.insert(0, (a[i - 1], b[j - 1]))
            i -= 1
            j -= 1
        elif matrix[i][j][1] == LEFT:
            alignment.insert(0, (None, b[j - 1]))
            j -= 1
        else: # UP
            alignment.insert(0, (a[i - 1], None))
            i -= 1

    return alignment

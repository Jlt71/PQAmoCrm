let
amoFn = (method as text, domen as text, login as text, hash as text, limits as nullable number) =>
    let
        authQuery =
            [
                USER_LOGIN=login,
                USER_HASH=hash
                ],
        url = "https://"&domen&".amocrm.ru",
        limit = if limits = null then 20000 else limits,

        githubFn = (function as text) =>
            let
                sourceFn = Expression.Evaluate(
                    Text.FromBinary(
                        Binary.Buffer(
                            Web.Contents("https://raw.githubusercontent.com/masaniy/PQAmoCrm/master/get"&function&".m")
                        )
                    ), [
                        #"Web.Contents" = Web.Contents,
                        #"Json.Document" = Json.Document,
                        #"Text.Combine" = Text.Combine,
                        #"Splitter.SplitByNothing" = Splitter.SplitByNothing,
                        #"JoinKind.LeftOuter" = JoinKind.LeftOuter,
                        #"ExtraValues.Error" = ExtraValues.Error,                        
                        #"Record.Combine" = Record.Combine,
                        #"Record.ToTable" = Record.ToTable,
                        #"Table.ExpandRecordColumn" = Table.ExpandRecordColumn,
                        #"Table.TransformColumnTypes" = Table.TransformColumnTypes,
                        #"Table.First" = Table.First,
                        #"Table.FromList" = Table.FromList,
                        #"Table.SelectColumns" = Table.SelectColumns,
                        #"Table.ExpandListColumn" = Table.ExpandListColumn,
                        #"Table.AddColumn" = Table.AddColumn,
                        #"Table.RemoveColumns" = Table.RemoveColumns,                        
                        #"Table.FromRecords" = Table.FromRecords,
                        #"Table.SelectRows" = Table.SelectRows,
                        #"Table.Pivot" = Table.Pivot,
                        #"Table.NestedJoin" = Table.NestedJoin,                       
                        #"Table.ExpandTableColumn" = Table.ExpandTableColumn                    
                    ]
                    )
            in
                sourceFn,

        generateList = List.Generate(()=>0, each _ < limit, each _ + 500),
        listToTable = Table.FromList(generateList, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
        numberToText = Table.TransformColumnTypes(listToTable,{{"Column1", type text}}),

        getMethod = githubFn(Text.Proper(method)),

        getFnToTable = Table.AddColumn(numberToText, Text.Proper(method), each getMethod([Column1], url, authQuery)),
        removeErrors = Table.RemoveRowsWithErrors(getFnToTable, {Text.Proper(method)}),
        removeColumn = Table.RemoveColumns(removeErrors,{"Column1"})
    in
        removeColumn
in
    amoFn

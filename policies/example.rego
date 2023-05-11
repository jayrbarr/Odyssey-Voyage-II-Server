package graphql.authz

import future.keywords.in
import future.keywords.every

default allow := false

query_ast := graphql.parse(input.body.query, input.sdl)
queryPolicy := ["me", "featuredListings"]

nodes[node] {
    some node
    walk(query_ast, node)
}

all_queries := [ operation |
    [_, operation] = nodes[_]
    operation.Operation == "query"
    operation.SelectionSet
]

allow {
    all_queries != {}
    every query in all_queries {
        every top_level in query.SelectionSet {
            arrContains(queryPolicy, top_level)
        }
    }
}

arrContains(arr, elem) {
    arr[_] == elem.Name
}

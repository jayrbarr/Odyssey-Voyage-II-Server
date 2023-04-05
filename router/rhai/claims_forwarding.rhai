fn subgraph_service(service, subgraph) {
    let f = |request| {
      // Note: APOLLO_AUTHENTICATION_JWT_CLAIMS is a Rhai-scope constant with
      // value `apollo_authentication::JWT::claims`
      let claims = request.context[APOLLO_AUTHENTICATION_JWT_CLAIMS];
      if claims ==() {
        throw #{
          status: 401
        };
      }
      let keys = claims.keys();
      // Add each claim key-value pair as a separate HTTP header
      for key in claims.keys() {
        if claims[key].type_of() == "i64" {request.subgraph.headers[key] = claims[key].to_string()} else {request.subgraph.headers[key] = claims[key]}
      }
    };
  
    service.map_request(f);
  }
// At the supergraph_service stage, register callbacks for processing requests
fn supergraph_service(service) {
    const request_callback = Fn("process_request"); // This is standard Rhai functionality for creating a function pointer
    service.map_request(request_callback); // Register the callback
}
  fn process_request(request) {
    try {
        // Note: APOLLO_AUTHENTICATION_JWT_CLAIMS is a Rhai-scope constant with
        // value `apollo_authentication::JWT::claims`
        let claims = request.context[APOLLO_AUTHENTICATION_JWT_CLAIMS];
        if claims == () {
            throw #{
                status: 401,
                message: "No claims presented in this request"
            };
        }
        if !claims.contains("iss") {
            throw #{
                status: 401,
                message: "No issuer presented in this request"
            };
        }
        if claims["iss"] != "https://t-mobile.oktapreview.com/oauth2/ausfj21w4dOqib1WD0h7" {
            throw #{
                status: 401,
                message: `Issuer ${claims.iss} is not accepted here`
            };
        }
        // Happy path: We have valid claims from the correct idP.
        // Proceed accordingly (in this case, we just log the claims).
        print(`claims: ${claims}`);
    }
    catch(err)
    {
        // log any errors
        log_error(`Error during claims processing: ${err}`);
        throw err;
    }
}
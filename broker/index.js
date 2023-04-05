import express from 'express';
import opaAuthz from './opa-service.js';
import * as dotenv from 'dotenv';
dotenv.config();

const app = express();
const port = 4041;
app.use(express.json());

app.get('/healthz', (_, res) => {
    res.status(200);
});

app.post('/', async (req, res) => {
    if (req.body.body.operationName != 'IntrospectionQuery') {
        const allow = await opaAuthz(req.body)
        console.log(`Allow: ${allow}`)
        if (allow) {
            res.json(req.body)
        } else {
            const responseBody = req.body
            responseBody.control = { 'break': 401}
            responseBody.body = {
                'errors': [
                  {
                    'message': 'Not authenticated.',
                    'extensions': {
                      'code': 'ERR_UNAUTHENTICATED'
                    }
                  }
                ]
              }
            res.json(responseBody)
        }
    } else {
        res.json(req.body)
    }
})

app.listen(port, () => console.log(`Router broker listing on http://localhost:${port}`));

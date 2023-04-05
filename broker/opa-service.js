import axios from "axios";
import { writeFileSync } from 'fs';

// Query OPA for an authz decision, using an input JSON object.
export default async (body) => {
  let out = false;

  console.log("Checking body...");
  console.dir(body);
  const input = {
    input: body
  }
  await axios
    .post(process.env.OPA_PROXY, input)
    .then(res => {
      console.log("Response:");
      console.dir(res.data.result.all_queries);
      writeFileSync('./data.json', JSON.stringify(res.data.result.all_queries, null, 2) , 'utf-8');
      out = res.data?.result?.allow;
    })
    .catch(error => {
      console.error(error);
      out = false;
    });
 
  return out;
}

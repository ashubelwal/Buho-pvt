import { LightningElement, wire } from 'lwc';
import { gql, graphql } from 'lightning/uiGraphQLApi';

export default class AgentConsoleWrapper extends LightningElement {
    agency;

    @wire(graphql, {
        query: gql`
            query GetBuhoInsuranceContact {
                uiapi {
                    query {
                        Contact(
                            where: { Name: { eq: "Buho Insurance" } }
                            first: 1
                        ) {
                            edges {
                                node {
                                    Id
                                }
                            }
                        }
                    }
                }
            }
        `,
    })
    wiredContact({ data, errors }) {
        if (data) {
            const edges = data.uiapi.query.Contact.edges;
            if (edges && edges.length > 0) {
                this.agency = edges[0].node.Id;
            }
        }
        if (errors) {
            console.error('GraphQL errors:', errors);
        }
    }
}
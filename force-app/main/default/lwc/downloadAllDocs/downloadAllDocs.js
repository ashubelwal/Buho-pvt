import { LightningElement } from 'lwc';
import downloadDocs from '@salesforce/apex/downloadDocsAttchments.downloadDocs'

export default class DownloadAllDocs extends LightningElement {
    AllData;
    async connectedCallback() {
        const data = await downloadDocs();
        let filterDateData = [];
        console.log('data' + JSON.stringify(data, null, 4));
        this.AllData = [...data];
        data.map((eachData) => {
            if (new Date(eachData.CreatedDate).getMonth() == 1 && new Date(eachData.CreatedDate).getDate() == 3 && eachData.BodyLength > 1) {
                eachData.url = '/servlet/servlet.FileDownload?file=' + eachData.Id;
                // eachData.url = 'sfc/servlet.shepherd/version/download/' + eachData.Id + '?asPdf=false&operationContext=S1';
                filterDateData.push(eachData);
            }

        })

        let filterWithLatter = filterDateData.filter((NameStart) => NameStart.Name.startsWith("A"));
        // //   console.log('data'+ JSON.stringify(data, null, 4));
        console.log('filterDateData' + JSON.stringify(filterDateData, null, 4));
        console.log('filterWithLatter' + JSON.stringify(filterWithLatter, null, 4));
        this.AllData = filterWithLatter;
    }

    downloadFiles() {
        this.AllData.map((data) => {
            console.log(data.Body, ' ', typeof data.Body);
            this.saveFile(data.url, data.Name)
        })
    }

    async saveFile(bytesbase64, fileName) {
        console.log('--saveFile--');
        // const blob = new Blob([bytesbase64], {
        //     type: 'text/plain' // or whatever your Content-Type is
        //   });
        // const strings = await blob.text();
        // console.log('--strings---'+ strings);
        // const type = blob.type;
        // console.log('--type---'+ type);
        // const blob2 = new Blob([strings], { type: type });

        // console.log('--blob2---'+ blob2);  https://mexinsurance.file.force.com/servlet/servlet.FileDownload?file=00P6R00007OmR4jUAF

        let fileUrl = 'https://mexinsurance.file.force.com/' + bytesbase64;
        fetch(fileUrl)
            .then((res) => res.blob()).then(
                blob => console.log('---blob--'+ blob)
            )
            
            // .then(blob => {
            //     let link = window.document.createElement("a");
            //     link.href = window.URL.createObjectURL(blob, { type: 'text/plain' });
            //     link.download = fileName;
            //     document.body.appendChild(link)
            //         ;
            //     link.click();
            //     document.body.removeChild(link);
            // })

    }
}
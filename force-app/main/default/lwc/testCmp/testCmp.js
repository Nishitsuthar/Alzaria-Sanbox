import { LightningElement, api, track, wire } from "lwc";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import GanttStyle from "@salesforce/resourceUrl/buildertek__BT_Bryntum_NewGanttCss";
import GANTTModule from "@salesforce/resourceUrl/buildertek__BT_Bryntum_NewGantt_ModuleJS";

export default class TestCmp extends LightningElement {

    renderedCallback(){
        try {
            Promise.all([
                loadScript(this, GANTTModule),
                loadStyle(this, GanttStyle + "/gantt.stockholm.css"),
            ])
            .then(() => {
                console.log("*******LIBRARY LOADED SUCCESSFULLY******");
            })
            .catch((error) => {
                console.log('error ',error);
            });
        } catch (error) {
            console.log('error ',error);
        }
    }
}
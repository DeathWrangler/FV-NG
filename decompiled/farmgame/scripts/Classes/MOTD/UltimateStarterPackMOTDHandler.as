package Classes.MOTD
{
   import Classes.Constants.Experiments;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Managers.ExperimentManager;
   
   public class UltimateStarterPackMOTDHandler extends CustomWindowMOTDHandler
   {
      
      private static var CUSTOM_ACTION_TYPE:String = "customActionType";
      
      private static var CUSTOM_ACTION_PARAMS:String = "customActionParams";
      
      private var m_itemName:String;
      
      public function UltimateStarterPackMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
         if(Boolean(currentMOTD) && Boolean(currentMOTD.customWindowParams) && Boolean(currentMOTD.customWindowParams.item))
         {
            this.m_itemName = currentMOTD.customWindowParams.item;
         }
      }
      
      override protected function acceptMOTD() : void
      {
         var customActionType:String = null;
         var customActionFunction:Function = null;
         super.acceptMOTD();
         var actionParams:Object = null;
         if(m_currentMOTD.hasOwnProperty(CUSTOM_ACTION_PARAMS))
         {
            actionParams = m_currentMOTD[CUSTOM_ACTION_PARAMS];
         }
         if(Boolean(actionParams) && actionParams.hasOwnProperty(CUSTOM_ACTION_TYPE))
         {
            customActionType = actionParams[CUSTOM_ACTION_TYPE];
            if(customActionType in this)
            {
               customActionFunction = this[customActionType] as Function;
               if(customActionFunction != null)
               {
                  customActionFunction.apply(null,[actionParams]);
               }
               else
               {
                  ErrorManager.addError(customActionType + " is not a function");
               }
            }
            else
            {
               ErrorManager.addError("Invalid MOTD customwindowaction type, " + customActionType + " missing");
            }
         }
         else
         {
            ErrorManager.addError("Missing MOTD customwindowaction type, " + CUSTOM_ACTION_TYPE + " in " + CUSTOM_ACTION_PARAMS + " missing");
         }
      }
      
      public function openMiniMarket(actionParams:Object) : void
      {
         var itemList:Array = null;
         var expManager:ExperimentManager = null;
         var variant:Number = NaN;
         var checkVisible:Boolean = false;
         var hideCloseButton:Boolean = false;
         if(actionParams.hasOwnProperty("itemList"))
         {
            itemList = [];
            expManager = new ExperimentManager();
            variant = Global.eosManager.getEosVariant(Experiments.EXPERIMENT_FLASH_XTL_ULTIMATE_STARTER);
            itemList.push(actionParams["itemList"].item.toString() + (variant - 1).toString());
            checkVisible = true;
            if(actionParams.hasOwnProperty("checkItemVisibility"))
            {
               if(actionParams["checkItemVisibility"] == "false")
               {
                  checkVisible = false;
               }
            }
            hideCloseButton = false;
            UI.displayMiniMarketDialog(itemList,"motd","",null,true,false,hideCloseButton,false);
         }
      }
   }
}


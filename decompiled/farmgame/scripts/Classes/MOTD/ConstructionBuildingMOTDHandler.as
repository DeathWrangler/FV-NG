package Classes.MOTD
{
   import Display.DataDrivenOkayPopup;
   import Display.UI;
   
   public class ConstructionBuildingMOTDHandler extends MOTDHandler
   {
      
      protected static const USER_FLOW_COMPLETED_BUILDING:Number = 0;
      
      protected static const USER_FLOW_CONSTRUCT_BUILDING:Number = 1;
      
      protected static const USER_FLOW_CONSTRUCT_GIFTBOX:Number = 2;
      
      protected static const USER_FLOW_NO_BUILDING:Number = 3;
      
      private static const ITEM_NAMES_DEFAULT_PARTS:Array = ["brick","nail","woodenboard"];
      
      private static const ITEM_QUANTITY_DEFAULT_PARTS:int = 3;
      
      public function ConstructionBuildingMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override public function execute() : void
      {
         var unfinishedParts:Array = null;
         var unfinishedPartQuantity:int = 0;
         var partName:String = null;
         var params:Array = null;
         var displayPopup:DataDrivenOkayPopup = null;
         var finishedBuildingName:String = this.getFinishedBuildingName();
         var constructionBuildingName:String = this.getConstructionBuildingName();
         var finishedItems:Array = Global.world.getObjectsByName(finishedBuildingName);
         var constructionItems:Array = Global.world.getObjectsByName(constructionBuildingName);
         var giftConstructionItems:Number = Global.player.getGiftCountForItem(constructionBuildingName);
         if(finishedItems.length > 0)
         {
            m_callbackData.userFlow = USER_FLOW_COMPLETED_BUILDING;
            m_callbackData.gift = this.getFinishedGiftName();
            Global.player.addGift(m_callbackData.gift);
         }
         else if(constructionItems.length > 0)
         {
            m_callbackData.userFlow = USER_FLOW_CONSTRUCT_BUILDING;
            unfinishedParts = this.getUnfinishedPartNames();
            unfinishedPartQuantity = this.getUnfinishedPartQuantity();
            for each(partName in unfinishedParts)
            {
               Global.player.addGift(partName,"0",unfinishedPartQuantity);
            }
         }
         else if(giftConstructionItems > 0)
         {
            m_callbackData.userFlow = USER_FLOW_CONSTRUCT_GIFTBOX;
            m_callbackData.gift = constructionBuildingName;
         }
         else
         {
            m_callbackData.userFlow = USER_FLOW_NO_BUILDING;
            m_callbackData.gift = constructionBuildingName;
            Global.player.addGift(m_callbackData.gift);
         }
         var dialogParameters:Object = this.getDialogParameters(m_callbackData.userFlow);
         if(dialogParameters.hasOwnProperty("imageUrl") && dialogParameters.hasOwnProperty("titleText") && dialogParameters.hasOwnProperty("bodyText") && dialogParameters.hasOwnProperty("buttonText"))
         {
            params = [dialogParameters.imageUrl,dialogParameters.bodyText,dialogParameters.titleText,dialogParameters.buttonText];
            displayPopup = new DataDrivenOkayPopup(MOTD_DIALOG_NAME_NO_CANCEL,params,this.acceptMOTD);
            UI.displayPopup(displayPopup,false);
            ztrack("impressions");
            Global.player.setSeenSessionFlag(SEEN_MOTD_SESSION_FLAG);
         }
         m_isFinished = true;
      }
      
      override protected function acceptMOTD() : void
      {
         super.acceptMOTD();
         switch(m_callbackData.userFlow)
         {
            case USER_FLOW_NO_BUILDING:
            case USER_FLOW_CONSTRUCT_GIFTBOX:
            case USER_FLOW_COMPLETED_BUILDING:
               Global.world.enterForcePlaceMode(m_callbackData.gift,true);
         }
      }
      
      protected function getDialogParameters(userFlow:int) : Object
      {
         return {};
      }
      
      protected function getFinishedBuildingName() : String
      {
         return "";
      }
      
      protected function getConstructionBuildingName() : String
      {
         return "";
      }
      
      protected function getFinishedGiftName() : String
      {
         return "";
      }
      
      protected function getUnfinishedPartNames() : Array
      {
         return ITEM_NAMES_DEFAULT_PARTS;
      }
      
      protected function getUnfinishedPartQuantity() : int
      {
         return ITEM_QUANTITY_DEFAULT_PARTS;
      }
   }
}


package Classes.MOTD
{
   import Classes.ConstructionBuilding;
   import Classes.StorageBuilding;
   import Classes.storage.StorageItem;
   import Classes.util.ZLocUtils;
   import Display.DataDrivenOkayPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.WorldManager;
   import Transactions.TRefreshGifts;
   import Transactions.TSawCraftshopV4MOTD;
   import flash.utils.Dictionary;
   
   public class CraftingV4MOTDHandler extends MOTDHandler
   {
      
      private static const ONBOARD_IMG_URL:String = "assets/dialogs/4d_elements/Crafting/Craftv4_MOTD.png";
      
      private static const USER_FLOW_COMPLETED_BUILDING:int = 0;
      
      private static const USER_FLOW_CONSTRUCT_BUILDING:int = 1;
      
      private static const USER_FLOW_FORCE_PLACE:int = 2;
      
      private static const INCOMPLETE_CRAFTSHOP_CODE:String = "4z";
      
      private static const COMPLETE_CRAFTSHOP_CODE:String = "4Z";
      
      public function CraftingV4MOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override public function execute() : void
      {
         var key:String = null;
         var inventoryItem:StorageItem = null;
         var itemCode:String = null;
         var index:int = 0;
         var constructionCraftshop:ConstructionBuilding = null;
         var imageUrl:String = "";
         var title:String = "";
         var text:String = "";
         var buttonText:String = "";
         var flowPrefix:String = "";
         var finishedCraftshops:Array = Global.craftConfigSettings.getCraftingWorkshopFinished();
         var buildableCraftshops:Array = Global.craftConfigSettings.getCraftingWorkshopBuildable();
         var finishedItems:Array = Global.world.getObjectsByNames(finishedCraftshops);
         var giftFinishedItems:Number = Global.player.getGiftCountForItems(finishedCraftshops);
         var constructionItems:Array = Global.world.getObjectsByNames(buildableCraftshops);
         var giftConstructionItems:Number = Global.player.getGiftCountForItems(buildableCraftshops);
         var storageBuildings:Array = Global.world.getObjectsByClass(StorageBuilding);
         var objects:Dictionary = Global.player.getInventory();
         if(objects)
         {
            for(key in objects)
            {
               inventoryItem = objects[key] as StorageItem;
               if(Boolean(inventoryItem) && inventoryItem.quantity > 0)
               {
                  itemCode = Global.farmGameSettingsManager.getItemCodeFromInventoryKey(key);
                  if(itemCode == INCOMPLETE_CRAFTSHOP_CODE || itemCode == COMPLETE_CRAFTSHOP_CODE)
                  {
                     Global.player.removeInventoryItem(key,1,WorldManager.HOME_INVENTORY_ID);
                     Global.player.removeInventoryItem(key,1,WorldManager.ENGLAND_INVENTORY_ID);
                  }
               }
            }
         }
         var finishedCraftshopslength:int = int(finishedCraftshops.length);
         for(var removeCount:Number = 0; removeCount < giftConstructionItems; removeCount++)
         {
            for(index = 0; index < finishedCraftshopslength; index++)
            {
               Global.player.removeGift(null,finishedCraftshops[index]);
            }
         }
         if(constructionItems.length > 0)
         {
            m_callbackData.userFlow = USER_FLOW_CONSTRUCT_BUILDING;
            flowPrefix = "Flow_0";
            constructionCraftshop = constructionItems[0] as ConstructionBuilding;
            constructionCraftshop.transformBuilding();
         }
         else if(finishedItems.length > 0)
         {
            m_callbackData.userFlow = USER_FLOW_COMPLETED_BUILDING;
            flowPrefix = "Flow_0";
         }
         else
         {
            m_callbackData.userFlow = USER_FLOW_FORCE_PLACE;
            flowPrefix = "Flow_1";
            m_callbackData.gift = finishedCraftshops[0];
            if(giftFinishedItems <= 0)
            {
               Global.player.addGift(m_callbackData.gift);
            }
         }
         imageUrl = ONBOARD_IMG_URL;
         title = ZLocUtils.t("Dialogs","MOTD_craftingv4_" + flowPrefix + "_Title");
         text = ZLocUtils.t("Dialogs","MOTD_craftingv4_" + flowPrefix + "_Text");
         buttonText = ZLocUtils.t("Dialogs","MOTD_craftingv4_" + flowPrefix + "_ButtonText");
         var params:Array = [imageUrl,text,title,buttonText];
         var displayPopup:DataDrivenOkayPopup = new DataDrivenOkayPopup(MOTD_DIALOG_NAME_NO_CANCEL,params,this.acceptMOTD);
         UI.displayPopup(displayPopup,false);
         super.execute();
      }
      
      override protected function acceptMOTD() : void
      {
         TransactionManager.addTransaction(new TRefreshGifts(),false);
         TransactionManager.addTransaction(new TSawCraftshopV4MOTD(m_currentMOTD,m_callbackData));
         TransactionManager.addTransaction(new TRefreshGifts(),true);
      }
   }
}


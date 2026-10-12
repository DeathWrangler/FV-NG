package GameMode
{
   import Classes.Constants.ClickTrackingConstants;
   import Classes.ItemInstance;
   import Classes.ZItem.FarmItem;
   import Classes.npc.ModelFarmNPC;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Constants;
   import Managers.ClickTrackingManager;
   import Managers.FarmStatsManager;
   import Managers.NPCManager;
   import Widgets.Constants.Market.Currency;
   import flash.events.MouseEvent;
   
   public class GMModelFarmVisit extends GMVisit
   {
      
      private static const TOOLTIP_SUBS_QUANTITY:String = "quantity";
      
      public function GMModelFarmVisit(hostId:String)
      {
         super(hostId);
      }
      
      override protected function getTagUrl() : String
      {
         var tagURL:String = null;
         var modelFarmNpc:ModelFarmNPC = NPCManager.getInstance().activeNpc as ModelFarmNPC;
         if(modelFarmNpc)
         {
            tagURL = modelFarmNpc.getLETagImageUrl();
         }
         return tagURL;
      }
      
      override protected function get itemPurchasingEnabled() : Boolean
      {
         return true;
      }
      
      override protected function getSelectableTypes() : int
      {
         return Constants.WORLDOBJECT_ALL_EXCEPT_AVATAR;
      }
      
      override protected function canPurchaseFarmItem(farmItem:FarmItem) : Boolean
      {
         return Boolean(farmItem) && farmItem.buyableFromModelFarm;
      }
      
      override protected function selectPurchasableItem(itemInst:ItemInstance, event:MouseEvent = null) : void
      {
         var tooltipKey:String = null;
         var tooltipSubs:Object = null;
         var market:String = null;
         var farmItem:FarmItem = itemInst.getItem();
         if(farmItem)
         {
            tooltipKey = "ModelFarm_MouseOverText_Buy_";
            tooltipSubs = {"item":ZLocUtils.tk_pk(itemInst.getItemFriendlyName())};
            market = farmItem.market;
            if(market == Currency.COINS)
            {
               tooltipKey += "Coins";
               tooltipSubs[TOOLTIP_SUBS_QUANTITY] = farmItem.cost;
            }
            else if(market == Currency.CASH)
            {
               tooltipKey += "Cash";
               tooltipSubs[TOOLTIP_SUBS_QUANTITY] = farmItem.cash;
            }
            else
            {
               tooltipKey += "Both";
               tooltipSubs[TOOLTIP_SUBS_QUANTITY + "A"] = farmItem.cost;
               tooltipSubs[TOOLTIP_SUBS_QUANTITY + "B"] = farmItem.cash;
            }
            itemInst.setToolTip(ZLocUtils.t("FarmGame",tooltipKey,tooltipSubs));
         }
      }
      
      override protected function selectNonPurchasableItem(itemInst:ItemInstance, event:MouseEvent = null) : void
      {
         if(itemInst)
         {
            if(itemInst.getItem().buyableWhileVisiting)
            {
               itemInst.setToolTip(ZLocUtils.t("FarmGame","ModelFarm_MouseOverText_NoBuy",{"item":ZLocUtils.tk_pk(itemInst.getItemFriendlyName())}));
            }
            else
            {
               itemInst.setToolTip(ZLocUtils.t("FarmGame","ModelFarm_MouseOverText_Crop",{"item":ZLocUtils.tk_pk(itemInst.getItemFriendlyName())}));
            }
         }
      }
      
      override protected function getCursor() : Object
      {
         return null;
      }
      
      override protected function canBeClicked(event:MouseEvent) : Boolean
      {
         return true;
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         var item:ItemInstance = null;
         var farmItem:FarmItem = null;
         if(m_highlightedObject)
         {
            ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_FARM_OBJECT);
            if(canPurchaseHighlightedObject())
            {
               item = m_highlightedObject as ItemInstance;
               if(item != null)
               {
                  farmItem = item.getItem();
                  if(farmItem != null)
                  {
                     FarmStatsManager.count("model_farm","clicks_item",farmItem.name);
                     UI.displayMarketPreviewWindow(farmItem);
                  }
               }
            }
         }
      }
   }
}


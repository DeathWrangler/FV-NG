package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import flash.events.MouseEvent;
   
   public class FMAirship extends Decoration
   {
      
      public static const MINIMUM_PROMPT_SELL_PRICE:Number = 1000;
      
      public function FMAirship(itemName:String = null)
      {
         super(itemName);
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case MOVE_OBJECT:
                  this.move();
                  break;
               case SELL_OBJECT:
                  this.sell();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      override protected function updateToolTipText() : void
      {
         var frName:String = null;
         var notes:String = null;
         var item:FarmItem = this.getItem();
         if(isHighlighted() && Boolean(m_item))
         {
            if("" != m_toolTipOverride)
            {
               setToolTip(m_toolTipOverride);
            }
            else
            {
               frName = ZLocUtils.tk_pk_asTitle(getItemFriendlyName());
               notes = m_item.tooltipNotes;
               if(notes != "")
               {
                  if(item.isLimitedItem())
                  {
                     notes = ZLocUtils.t("Items",item.name + "_notes",{"date":item.getLimitedEndDate()});
                     if(item.isWithinLimitedEndDate())
                     {
                        frName += "\n" + notes;
                     }
                  }
                  else
                  {
                     frName += "\n" + notes;
                  }
               }
               setToolTip(frName);
            }
            updateToolTipPosition();
         }
      }
      
      override protected function getMenuItems() : Array
      {
         var item:FarmItem = this.getItem();
         var menuItems:Array = new Array();
         menuItems.push({
            "label":ZLocUtils.t("FarmGame","Move"),
            "action":MOVE_OBJECT
         });
         menuItems.push({
            "label":ZLocUtils.t("FarmGame","Sell"),
            "action":SELL_OBJECT
         });
         return menuItems;
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
      }
      
      override protected function canShowStoreMenuItem() : Boolean
      {
         return true;
      }
      
      override public function sell() : void
      {
         var sellMessage1:String = null;
         var combinedMessage:String = null;
         var popup:GenericPopup = null;
         var item:FarmItem = this.getItem();
         var sellPrice:int = getSellPrice();
         if((Global.quickDeleteOn || Global.persistentSell) && sellPrice < MINIMUM_PROMPT_SELL_PRICE)
         {
            this.sellConfirmationHandler();
         }
         else
         {
            sellMessage1 = ZLocUtils.t("FarmGame","SellObjectSpecific",{
               "item":ZLocUtils.tk_pk(item.friendlyName),
               "quantity":item.coins
            });
            combinedMessage = sellMessage1;
            popup = new GenericPopup(combinedMessage,GenericPopup.TYPE_ACCEPTCANCEL,this.sellConfirmationHandler,GenericPopup.GENERIC_ASSET_MED,"",true);
            UI.displayPopup(popup,true);
         }
      }
      
      override protected function sellConfirmationHandler(event:GenericPopupEvent = null) : void
      {
         super.sellConfirmationHandler(event);
         var result:Boolean = false;
         if(event != null)
         {
            result = event.button == GenericPopup.YES;
         }
         else
         {
            result = true;
         }
         if(result == true)
         {
            FarmStatsManager.count("farmersinsuranceairship","dialogue_sell_airship","accept");
         }
         else
         {
            FarmStatsManager.count("farmersinsuranceairship","dialogue_sell_airship","cancel");
         }
      }
   }
}


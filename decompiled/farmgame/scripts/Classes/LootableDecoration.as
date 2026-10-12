package Classes
{
   import Classes.Constants.ToasterIconPaths;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Managers.ToasterManager;
   import Transactions.TOpenLootItem;
   import Widgets.Windows.TwoIconTitleToasterWindow;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class LootableDecoration extends Decoration
   {
      
      public static const OPEN_OBJECT:String = "open";
      
      public static const OPEN_OVERLAY_URL_DEFAULT:String = "assets/effects/effect_mysterycrate.swf";
      
      public static const OPEN_GIFTBOX_OVERLAY_URL_DEFAULT:String = "assets/effects/effect_mysterycrate3.swf";
      
      private static const WON_ITEM_SCALE:Number = 0.5;
      
      private static const LOOTABLE_ITEM_SCALE:Number = 0.5;
      
      private static const WON_ITEM_OFFSET:Point = new Point(15,8);
      
      private static const LOOTABLE_ITEM_OFFSET:Point = new Point(7,0);
      
      protected var m_isGift:Boolean = false;
      
      public function LootableDecoration(itemName:String = null)
      {
         super(itemName);
      }
      
      public static function getStringStatic(localizationSuffix:String, localizationPrefix:String, params:Object = null, item:FarmItem = null) : String
      {
         var message:String = null;
         var itemFriendlyNameKey:String = "";
         if(ZLocUtils.hasString("Dialogs",localizationPrefix + localizationSuffix))
         {
            message = ZLocUtils.t("Dialogs",localizationPrefix + localizationSuffix,params);
         }
         else
         {
            if(!params || !params.item)
            {
               if(!item)
               {
                  itemFriendlyNameKey = "Items:" + localizationPrefix + "_friendlyName";
               }
               else
               {
                  itemFriendlyNameKey = item.friendlyName;
               }
               params = {
                  "name":ZLocUtils.tk_pk_asTitle(itemFriendlyNameKey),
                  "item":ZLocUtils.tk_pk_asTitle(itemFriendlyNameKey)
               };
            }
            if(item.type == "egg" || item.subType == "egg" || item.subsubtype == "egg")
            {
               message = ZLocUtils.t("Dialogs","MysteryEggGeneric" + localizationSuffix,params);
            }
            else
            {
               message = ZLocUtils.t("Dialogs","MysteryBoxGeneric" + localizationSuffix,params);
            }
         }
         return message;
      }
      
      override protected function getMenuItems() : Array
      {
         return [{
            "label":ZLocUtils.t("FarmGame","Open"),
            "action":OPEN_OBJECT
         },{
            "label":ZLocUtils.t("FarmGame","Move"),
            "action":MOVE_OBJECT
         }];
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case OPEN_OBJECT:
                  this.open();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      protected function open() : void
      {
         var message:String = null;
         var params:Object = null;
         if(!Global.player.hasGiftBoxCapacity())
         {
            message = this.getString("_TooManyGifts");
            UI.displayMessage(message,GenericPopup.TYPE_OK);
         }
         else
         {
            params = new Object();
            params.isGift = this.m_isGift;
            if(this.m_isGift)
            {
               Global.player.removeGift(null,this.itemName);
            }
            else
            {
               detach();
            }
            TransactionManager.addTransaction(new TOpenLootItem(this,params),true);
         }
      }
      
      public function giftBoxOpen() : void
      {
         this.m_isGift = true;
         this.open();
      }
      
      public function get itemName() : String
      {
         return m_item.name;
      }
      
      public function getOpenOverlayUrl() : String
      {
         return OPEN_OVERLAY_URL_DEFAULT;
      }
      
      public function getGiftBoxOverlayUrl() : String
      {
         return OPEN_GIFTBOX_OVERLAY_URL_DEFAULT;
      }
      
      public function getString(localizationSuffix:String, localizationPrefix:String = null, params:Object = null) : String
      {
         if(!localizationPrefix)
         {
            localizationPrefix = this.itemName;
         }
         return getStringStatic(localizationSuffix,localizationPrefix,params,m_item);
      }
      
      public function displayPostOpenPopup(wonItem:FarmItem, closeCallback:Function) : void
      {
         var wonItemXp:String = null;
         var titleMsg:String = ZLocUtils.t("Dialogs","Yeehaw");
         var lootableItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.itemName);
         if(FarmGameSettingsManager.isInDataSourceExperiment())
         {
            wonItemXp = wonItem.getStringFromDataSource("XP");
         }
         else
         {
            wonItemXp = wonItem.xml.XP;
         }
         var msg:String = this.getString("_Opened",lootableItem.name,{
            "name":ZLocUtils.tk_pk(lootableItem.friendlyName),
            "item":ZLocUtils.tk_pk(wonItem.friendlyName),
            "quantity":wonItemXp
         });
         ToasterManager.getInstance().add(new TwoIconTitleToasterWindow(titleMsg,msg,wonItem.icon,lootableItem.icon,ToasterIconPaths.DIALOG_ASSET,WON_ITEM_SCALE,LOOTABLE_ITEM_SCALE,WON_ITEM_OFFSET,LOOTABLE_ITEM_OFFSET,null,true,false,null,closeCallback));
      }
   }
}


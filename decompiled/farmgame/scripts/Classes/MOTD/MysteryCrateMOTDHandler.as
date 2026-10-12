package Classes.MOTD
{
   import Classes.MysteryCrateBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.Dialogs.GenericDialog;
   import Display.UI;
   import GameMode.GMBuild;
   import Managers.ToasterManager;
   import Widgets.Windows.IconTitleToasterWindow;
   import flash.geom.Point;
   
   public class MysteryCrateMOTDHandler extends CustomWindowMOTDHandler
   {
      
      public function MysteryCrateMOTDHandler(currentMOTD:Object)
      {
         super(currentMOTD);
      }
      
      override protected function acceptMOTD() : void
      {
         var itemName:String = null;
         var item:FarmItem = null;
         var canPlace:Boolean = false;
         var partName:String = null;
         super.acceptMOTD();
         if(m_currentMOTD.freeGift)
         {
            itemName = m_currentMOTD.freeGift;
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            canPlace = !item.checkItemLimit(false);
            partName = Global.flashHotParams["MYSTERY_CRATE_PART_TYPE"];
            switch(Global.flashHotParams["MYSTERY_CRATE_PART_TYPE"])
            {
               case MysteryCrateBuilding.SNIPS_PART_NAME:
                  partName = MysteryCrateBuilding.PART_TYPE_SNIPS;
                  break;
               case MysteryCrateBuilding.SCISSORS_PART_NAME:
               default:
                  partName = MysteryCrateBuilding.PART_TYPE_SCISSORS;
            }
            if(canPlace)
            {
               this.enterMysteryCrateMode(itemName,partName);
            }
         }
      }
      
      public function enterMysteryCrateMode(itemName:String, partName:String) : void
      {
         var giftItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         Global.world.addGameMode(new GMBuild(itemName,false,0,false));
         var toasterTitle:String = ZLocUtils.t("Crafting","PlacementToasterTitle");
         var toasterMessage:String = ZLocUtils.t("Dialogs","mysterycrate_toaster_message",{"part":partName});
         var icon:String = giftItem.iconUrl;
         ToasterManager.getInstance().togglePause(false);
         ToasterManager.getInstance().add(new IconTitleToasterWindow(toasterTitle,toasterMessage,icon,"assets/dialogs/FV_PlacementMode_BannerAd.swf",0.5,new Point(15,8)));
      }
      
      override protected function closeMOTD() : void
      {
         var dialog:GenericDialog = null;
         dialog = null;
         var callback:Function = function(isAccept:Boolean):void
         {
            dialog.destroy();
            acceptMOTD();
         };
         dialog = UI.showMessage(ZLocUtils.t("Dialogs","mysterycrate_MOTD_close_dialog"),UI.BUTTON_LAYOUT_ACCEPT_CANCEL,null,null,false,callback);
         super.closeMOTD();
      }
   }
}


package Classes.Quest.helperactions
{
   import Classes.MapResource;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericIconPopup;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import GameMode.GMBuild;
   
   public class StorageBuildingDialogHelperAction extends QuestHelperAction
   {
      
      private var m_buildingItem:FarmItem = null;
      
      public function StorageBuildingDialogHelperAction(questName:String, buildingItemCode:String)
      {
         super(questName);
         m_shouldCloseOnPerform = true;
         this.m_buildingItem = Global.farmGameSettingsManager.getFarmItemByCode(buildingItemCode);
      }
      
      override public function perform() : void
      {
         var worldObjects:Array = null;
         var buildingObj:Object = null;
         var popup:GenericIconPopup = null;
         super.perform();
         if(this.m_buildingItem != null)
         {
            worldObjects = Global.world.getObjectsByName(this.m_buildingItem.name);
            if(worldObjects.length > 0)
            {
               if(worldObjects[0] as MapResource is StorageBuilding)
               {
                  buildingObj = worldObjects[0] as Object;
                  if(buildingObj.hasOwnProperty("displayStorageDialog"))
                  {
                     worldObjects[0].displayStorageDialog();
                  }
               }
            }
            else if(this.m_buildingItem.buyable)
            {
               popup = new GenericIconPopup("Place the " + this.m_buildingItem.friendlyTitle + " now",GenericPopup.TYPE_OK,this.onEnterForcedPlacement,this.m_buildingItem.icon,false,false);
               popup.setAcceptTextName("GenericPlaceButton");
               UI.displayPopup(popup);
            }
         }
      }
      
      private function onEnterForcedPlacement(event:GenericPopupEvent) : void
      {
         var hasGift:Boolean = Global.player.getGiftCountForItem(this.m_buildingItem.name) > 0;
         Global.world.addGameMode(new GMBuild(this.m_buildingItem.name,hasGift,0,true,null));
         UI.closeGifts();
      }
      
      override public function get readableText() : String
      {
         return ZLocUtils.t("Quests","Helper_OpenStorageBuildingDialog_Button",{"item":ZLocUtils.tk_pk(this.m_buildingItem.friendlyName)});
      }
   }
}


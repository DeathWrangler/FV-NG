package Widgets.Windows.Crafting
{
   import Classes.Constants.WorldsConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import GameMode.GMBuild;
   
   public class FirstCraftingSiloWindow extends FirstMarketStallWindow
   {
      
      public function FirstCraftingSiloWindow(bushelCode:String)
      {
         super(bushelCode);
      }
      
      public static function getFirstCraftingSiloSeenFlag() : String
      {
         var result:String = "FirstCraftingSilo";
         var currentWorldType:String = Global.worldManager.currentWorldType;
         if(currentWorldType != WorldsConstants.WORLD_ID_HOME)
         {
            result = result + "_" + currentWorldType;
         }
         return result;
      }
      
      override protected function getBodyText() : String
      {
         var bushelItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(m_bushelCode);
         return ZLocUtils.t("Crafting","FirstCraftingSiloDialog_Body",{"bushelItem":ZLocUtils.tk_pk(bushelItem.friendlyName)});
      }
      
      override protected function getButtonText() : String
      {
         return ZLocUtils.t("FarmGame","PlaceNow");
      }
      
      override protected function startGameMode() : void
      {
         Global.world.addGameMode(new GMBuild("craftingsilo",true,0,false));
      }
      
      override protected function setSeenFlag() : void
      {
         Global.player.setSeenFlag(FirstCraftingSiloWindow.getFirstCraftingSiloSeenFlag());
      }
   }
}


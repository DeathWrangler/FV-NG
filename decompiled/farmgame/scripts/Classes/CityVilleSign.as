package Classes
{
   import Display.CityvilleLaunchPromoDialog;
   import Display.FarmDynamicDialog;
   import GameMode.GMDefault;
   import Managers.FarmStatsManager;
   
   public class CityVilleSign extends MapTrigger
   {
      
      public static const Y_OFFSET:Number = -12;
      
      public function CityVilleSign()
      {
         super("englandsign");
      }
      
      override public function loadObject(data:Object) : void
      {
         var xPosition:Number = (FarmGameWorld(m_outer).getGridWidth() >> 1) - (m_size.x >> 1);
         data.position = {
            "x":xPosition,
            "y":Y_OFFSET,
            "z":0
         };
         super.loadObject(data);
         FarmStatsManager.count("city_xpromo","billboard","impressions");
      }
      
      override public function onClick() : void
      {
         var visitCityDialog:CityvilleLaunchPromoDialog = FarmDynamicDialog.createDialog("cityvilleLaunchPromo",CityvilleLaunchPromoDialog) as CityvilleLaunchPromoDialog;
         if(visitCityDialog)
         {
            visitCityDialog.addImport("cityvilleLaunchPromo",null);
            visitCityDialog.setSign(this);
            visitCityDialog.setup();
            visitCityDialog.show();
         }
         FarmStatsManager.count("city_xpromo","billboard","impressions");
      }
      
      public function hideSign() : void
      {
         detach();
         Global.world.redrawObjectsOfClass(CityVilleSign);
      }
      
      override public function isDecoMoveSupported() : Boolean
      {
         return false;
      }
      
      override public function handleDecoMoveUnsupported() : void
      {
         this.onClick();
         Global.world.addGameMode(new GMDefault(),true);
      }
   }
}


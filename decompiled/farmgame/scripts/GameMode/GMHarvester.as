package GameMode
{
   import AvatarMode.AMHarvester;
   import Classes.Avatar.FarmAvatar;
   import Classes.Harvester;
   import Engine.Managers.SoundManager;
   import Managers.FarmStatsManager;
   import flash.geom.Point;
   
   public class GMHarvester extends GMMultiPlotHarvest
   {
      
      private static var m_soundAdded:Boolean = false;
      
      protected var m_equipment:Harvester = null;
      
      public function GMHarvester(harvester:Harvester = null)
      {
         super();
         if(!m_soundAdded)
         {
            SoundManager.addSound("tractorPlow",Global.getAssetURL("assets/sounds/equipment/sfx_tractor_plow.mp3"),false);
            SoundManager.addSound("tractorStop",Global.getAssetURL("assets/sounds/equipment/sfx_tractor_off.mp3"),false);
            m_soundAdded = true;
         }
         if(harvester == null)
         {
            harvester = Global.world.getEquipment(Harvester) as Harvester;
         }
         this.m_equipment = harvester;
         if(this.m_equipment)
         {
            m_actionSize = this.m_equipment.getActionSize();
            m_arrAcceptableTerrain = harvester.getSupportedTerrainCodes();
         }
         SoundManager.playSound("tractorStart");
         SoundManager.playSound("tractorIdle",0,9999);
      }
      
      override protected function addAvatarState(avatar:FarmAvatar, plots:Array, centerPos:Point) : void
      {
         FarmStatsManager.count("use_vehicle","use_harvester",(m_actionSize.x * m_actionSize.y).toString());
         avatar.getStateMachine().addState(new AMHarvester(avatar,plots,this.m_equipment as Harvester,centerPos),true);
      }
      
      override public function disableMode() : void
      {
         SoundManager.stopSound("tractorIdle");
         super.disableMode();
         SoundManager.playSound("tractorStop");
      }
      
      public function get harvester() : Harvester
      {
         return this.m_equipment;
      }
   }
}


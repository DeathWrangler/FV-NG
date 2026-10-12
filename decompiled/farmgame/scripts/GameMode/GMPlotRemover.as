package GameMode
{
   import AvatarMode.AMPlotRemover;
   import Classes.Avatar.FarmAvatar;
   import Classes.PlotRemover;
   import Engine.Managers.SoundManager;
   import Managers.FarmStatsManager;
   import flash.geom.Point;
   
   public class GMPlotRemover extends GMMultiPlotRemover
   {
      
      private static var m_soundAdded:Boolean = false;
      
      protected var m_equipment:PlotRemover = null;
      
      public function GMPlotRemover(plotRemover:PlotRemover = null)
      {
         super();
         if(!m_soundAdded)
         {
            SoundManager.addSound("tractorPlow",Global.getAssetURL("assets/sounds/equipment/sfx_tractor_plow.mp3"),false);
            SoundManager.addSound("tractorStop",Global.getAssetURL("assets/sounds/equipment/sfx_tractor_off.mp3"),false);
            m_soundAdded = true;
         }
         if(plotRemover == null)
         {
            plotRemover = Global.world.getEquipment(PlotRemover) as PlotRemover;
         }
         this.m_equipment = plotRemover;
         if(this.m_equipment)
         {
            m_actionSize = this.m_equipment.getActionSize();
            m_arrAcceptableTerrain = plotRemover.getSupportedTerrainCodes();
         }
         SoundManager.playSound("tractorStart");
         SoundManager.playSound("tractorIdle",0,9999);
      }
      
      override protected function addAvatarState(avatar:FarmAvatar, plots:Array, centerPos:Point) : void
      {
         FarmStatsManager.count("use_vehicle","use_plotremover",(m_actionSize.x * m_actionSize.y).toString());
         avatar.getStateMachine().addState(new AMPlotRemover(avatar,plots,this.m_equipment as PlotRemover,centerPos),true);
      }
      
      override public function disableMode() : void
      {
         SoundManager.stopSound("tractorIdle");
         super.disableMode();
         SoundManager.playSound("tractorStop");
      }
      
      override protected function isPlotRemover() : Boolean
      {
         return true;
      }
      
      public function get harvester() : PlotRemover
      {
         return this.m_equipment;
      }
   }
}


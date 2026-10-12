package GameMode
{
   import AvatarMode.AMResourceHarvester;
   import Classes.Avatar.FarmAvatar;
   import Classes.Constants.ClickTrackingConstants;
   import Classes.MapResource;
   import Classes.ResourceHarvester;
   import Engine.Managers.SoundManager;
   import Managers.ClickTrackingManager;
   import Managers.EquipmentSettingsManager;
   import Managers.FarmStatsManager;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   
   public class GMResourceHarvester extends GMMultiResourceHarvest
   {
      
      protected var m_equipment:ResourceHarvester;
      
      private var m_clickPhylum:String = null;
      
      public function GMResourceHarvester(cursorIcon:Class, clickPhylum:String, harvester:ResourceHarvester = null)
      {
         super();
         m_cursorImage = cursorIcon;
         this.m_clickPhylum = clickPhylum;
         if(!harvester)
         {
            harvester = Global.world.getEquipment(ResourceHarvester) as ResourceHarvester;
         }
         this.m_equipment = harvester;
         if(this.m_equipment)
         {
            m_actionSize = EquipmentSettingsManager.getInstance().getActionSizeByPartCount(this.m_equipment.equipmentPartsCount,this.m_equipment.getItem().code);
            m_resourceSize = this.m_equipment.getResourceSize();
         }
         SoundManager.addSound("tractorPlow",Global.getAssetURL("assets/sounds/equipment/sfx_tractor_plow.mp3"),false);
         SoundManager.addSound("tractorStop",Global.getAssetURL("assets/sounds/equipment/sfx_tractor_off.mp3"),false);
         SoundManager.playSound("tractorStart");
         SoundManager.playSound("tractorIdle",0,9999);
      }
      
      override protected function handleClick(event:MouseEvent) : void
      {
         super.handleClick(event);
         ClickTrackingManager.getInstance().countClick(ClickTrackingConstants.CLICK_TYPE_VEHICLE,this.m_clickPhylum);
      }
      
      override protected function addAvatarState(avatar:FarmAvatar, resources:Array, centerPos:Point) : void
      {
         FarmStatsManager.count("use_vehicle","use_resource_harvester",m_actionSize.x + "x" + m_actionSize.y);
         avatar.getStateMachine().addState(new AMResourceHarvester(avatar,resources,this.m_equipment,centerPos),true);
      }
      
      override public function disableMode() : void
      {
         SoundManager.stopSound("tractorIdle");
         super.disableMode();
         SoundManager.playSound("tractorStop");
      }
      
      override protected function isSelectable(resource:MapResource) : Boolean
      {
         var result:Boolean = false;
         if(Boolean(super.isSelectable(resource)) && EquipmentSettingsManager.getInstance().canEquipmentActOnResource(resource.getItem().code,this.m_equipment.getItem().code))
         {
            result = true;
         }
         return result;
      }
      
      public function get harvester() : ResourceHarvester
      {
         return this.m_equipment;
      }
   }
}


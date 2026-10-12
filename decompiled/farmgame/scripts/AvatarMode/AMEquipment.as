package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.Equipment;
   import Engine.Classes.World;
   import Engine.Managers.SoundManager;
   import flash.geom.Point;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import gs.TweenLite;
   
   public class AMEquipment extends AMMultiPlotAction
   {
      
      protected static var m_equipmentArray:Array = null;
      
      protected var m_actionEquipment:Equipment;
      
      public function AMEquipment(avatar:FarmAvatar, plots:Array, equipment:Equipment, centerPos:Point)
      {
         var className:String = null;
         var classType:Class = null;
         var name:String = null;
         super(avatar,plots,centerPos);
         m_equipment = equipment;
         if(null == m_equipmentArray)
         {
            m_equipmentArray = new Array();
         }
         if(m_equipment)
         {
            className = getQualifiedClassName(m_equipment);
            classType = getDefinitionByName(className) as Class;
            name = m_equipment.getItem().name;
            if(null == m_equipmentArray[name])
            {
               m_equipmentArray[name] = new classType(m_equipment.getItem().name,true);
            }
            this.m_actionEquipment = m_equipmentArray[name];
         }
      }
      
      public static function clearStaticStates() : void
      {
         m_equipmentArray = new Array();
      }
      
      override protected function hide() : void
      {
         super.hide();
         TweenLite.to(m_equipment,0.25,{"alpha":0.5});
         this.m_actionEquipment.setOuter(m_equipment.getOuter() as World);
         this.m_actionEquipment.setPosition(Math.max(m_centerPos.x - m_equipment.getSize().x / 2 - 0.1,0),Math.max(m_centerPos.y - m_equipment.getSize().y / 2 - 0.1,0));
         this.m_actionEquipment.conditionallyReattach();
         TweenLite.to(this.m_actionEquipment,0.25,{"alpha":1});
      }
      
      override protected function show() : void
      {
         super.show();
         TweenLite.to(m_equipment,0.25,{"alpha":1});
         TweenLite.to(this.m_actionEquipment,0.25,{
            "alpha":0,
            "onComplete":function():void
            {
               m_actionEquipment.detach();
            }
         });
      }
      
      override public function exit() : void
      {
         this.m_actionEquipment.setActionProgress(null);
         super.exit();
      }
      
      override public function enter() : void
      {
         super.enter();
         if(this.m_actionStarted)
         {
            SoundManager.playSound("tractorPlow");
         }
      }
      
      override public function reenter() : void
      {
         super.reenter();
         if(this.m_actionStarted)
         {
            SoundManager.playSound("tractorPlow");
         }
      }
      
      override protected function getEnergyForPlot(plotIndex:int) : int
      {
         return Global.player.hasUnlimitedFuelOfferActivated() ? 0 : int(this.m_actionEquipment.getEnergyCost());
      }
   }
}


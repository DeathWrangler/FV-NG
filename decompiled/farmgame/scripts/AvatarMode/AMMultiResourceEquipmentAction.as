package AvatarMode
{
   import Classes.Avatar.FarmAvatar;
   import Classes.ResourceEquipment;
   import Engine.Classes.World;
   import Engine.Managers.SoundManager;
   import flash.geom.Point;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import gs.TweenLite;
   
   public class AMMultiResourceEquipmentAction extends AMMultiResourceAction
   {
      
      protected static var m_equipmentArray:Array = null;
      
      protected var m_actionEquipment:ResourceEquipment;
      
      protected var m_equipment:ResourceEquipment;
      
      public function AMMultiResourceEquipmentAction(avatar:FarmAvatar, resources:Array, equipment:ResourceEquipment, centerPos:Point)
      {
         var className:String = null;
         var classType:Class = null;
         var name:String = null;
         super(avatar,resources,centerPos);
         this.m_equipment = equipment;
         if(!m_equipmentArray)
         {
            m_equipmentArray = new Array();
         }
         if(this.m_equipment)
         {
            className = getQualifiedClassName(this.m_equipment);
            classType = getDefinitionByName(className) as Class;
            name = this.m_equipment.getItem().name;
            if(!m_equipmentArray[name])
            {
               m_equipmentArray[name] = new classType(this.m_equipment.getItemName(),true);
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
         TweenLite.to(this.m_equipment,0.25,{"alpha":0.5});
         this.m_actionEquipment.setOuter(this.m_equipment.getOuter() as World);
         this.m_actionEquipment.setPosition(Math.max(m_centerPos.x - this.m_equipment.getSize().x / 2 - 0.1,0),Math.max(m_centerPos.y - this.m_equipment.getSize().y / 2 - 0.1,0));
         this.m_actionEquipment.conditionallyReattach();
         TweenLite.to(this.m_actionEquipment,0.25,{"alpha":1});
      }
      
      override protected function show() : void
      {
         super.show();
         TweenLite.to(this.m_equipment,0.25,{"alpha":1});
         TweenLite.to(this.m_actionEquipment,0.25,{
            "alpha":0,
            "onComplete":this.onShowTweenComplete
         });
      }
      
      private function onShowTweenComplete() : void
      {
         if(this.m_actionEquipment)
         {
            this.m_actionEquipment.detach();
         }
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
   }
}


package GameMode
{
   import Classes.Equipment;
   import Classes.FarmGameObject;
   import Classes.Idle.IdleTaskQueue;
   import Classes.Idle.ZapFirstPlacementDialogTask;
   import Classes.MapResource;
   import flash.events.MouseEvent;
   
   public class GMEquipmentPlace extends GMDecorationPlace
   {
      
      protected var m_upgradeParts:Number = 0;
      
      public function GMEquipmentPlace(equipmentType:String, isGift:Boolean = false, buildingId:Number = 0, upgradeParts:Number = 0, currency:String = "")
      {
         this.m_upgradeParts = upgradeParts;
         super(equipmentType,isGift,buildingId,true,currency);
      }
      
      override protected function setSelectedObject(itemClass:Class) : void
      {
         var equipment:Equipment = new itemClass(this.decorationType,false,this.m_upgradeParts);
         equipment.setPlaced(false);
         equipment.setOuter(Global.world);
         equipment.setPosition(m_highlightedPoint.x,m_highlightedPoint.y);
         m_selectedObject = equipment as FarmGameObject;
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         super.onMouseUp(event);
         IdleTaskQueue.getInstance().addTask(new ZapFirstPlacementDialogTask((m_selectedObject as MapResource).getItemName()));
         return true;
      }
   }
}


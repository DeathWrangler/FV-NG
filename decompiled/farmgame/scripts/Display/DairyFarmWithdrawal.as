package Display
{
   import Classes.StorageBuilding;
   import Classes.util.ZLocUtils;
   
   public class DairyFarmWithdrawal extends StorageWithdrawal
   {
      
      public function DairyFarmWithdrawal(storage:StorageBuilding)
      {
         super(storage);
      }
      
      override protected function setupCapacityBox() : void
      {
         ZLocUtils.setText(m_window,"gifts_mc.capacity_tf","Dialogs","Capacity",{"quantity":m_building.capacity});
         ZLocUtils.setText(m_window,"gifts_mc.current_tf","Dialogs","Current",{"quantity":m_building.count});
      }
   }
}


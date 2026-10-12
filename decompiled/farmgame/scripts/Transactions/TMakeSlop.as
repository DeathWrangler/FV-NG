package Transactions
{
   import Classes.PigpenBuilding;
   
   public class TMakeSlop extends TWorldState
   {
      
      private var m_bushelCode:String;
      
      private var m_building:PigpenBuilding;
      
      public function TMakeSlop(worldObj:PigpenBuilding, bushelCode:String)
      {
         super(worldObj);
         this.m_building = worldObj;
         this.m_bushelCode = bushelCode;
      }
      
      override public function perform() : void
      {
         signedWorldAction("makeSlop",this.m_bushelCode);
      }
   }
}


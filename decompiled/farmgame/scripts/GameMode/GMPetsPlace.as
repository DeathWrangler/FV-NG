package GameMode
{
   import Classes.FarmGameObject;
   import Classes.MapResource;
   import Classes.Pet;
   import Engine.Managers.TransactionManager;
   import Transactions.TPetsPlace;
   import flash.events.MouseEvent;
   
   public class GMPetsPlace extends GMObjectMove
   {
      
      private var m_animalType:String;
      
      private var m_petType:String;
      
      private var m_petGender:Number;
      
      private var m_petName:String;
      
      private var m_isCash:Boolean;
      
      public function GMPetsPlace(animalType:String, petType:String, petGender:Number, petName:String, isCash:Boolean)
      {
         this.m_animalType = animalType;
         this.m_petType = petType;
         this.m_petGender = petGender;
         this.m_petName = petName;
         this.m_isCash = isCash;
         super(null);
      }
      
      override public function onMouseMove(event:MouseEvent) : Boolean
      {
         var animal:Pet = null;
         if(!m_selectedObject)
         {
            m_highlightedPoint = getMouseTilePos();
            animal = new Pet(this.m_animalType);
            animal.setOuter(Global.world);
            animal.setPosition(m_highlightedPoint.x,m_highlightedPoint.y);
            animal.petName = this.m_petName;
            animal.petGender = this.m_petGender;
            animal.isCash = this.m_isCash;
            m_selectedObject = animal as FarmGameObject;
         }
         return super.onMouseMove(event);
      }
      
      override public function onMouseUp(event:MouseEvent) : Boolean
      {
         super.onMouseUp(event);
         if(m_objectPlacedSuccess)
         {
            Global.world.setDefaultGameMode();
            if(Global.player.tryBuy(m_selectedObject as MapResource,false))
            {
               TransactionManager.addTransaction(new TPetsPlace(m_selectedObject as Pet));
            }
         }
         return true;
      }
   }
}


package Classes
{
   import Display.UI;
   import Managers.OrderBoard.BobBerryManager;
   import Widgets.Windows.BobBerryFarmWindow;
   
   public class BobBerryFarmMapTrigger extends MapTrigger
   {
      
      public static const STATE_IDLE:String = "built_idle";
      
      public static const STATE_HAPPY:String = "built_happy";
      
      public static const STATE_BUBBLE_SMALL:String = "built_bubblesmall";
      
      public static const STATE_BUBBLE_BIG:String = "built_bubblebig";
      
      private var m_dialogUrl:String = "assets/dialogs/FV_BobsBerryFarm2014.swf";
      
      public function BobBerryFarmMapTrigger(itemName:String, stateToSet:String = "built_idle")
      {
         super(itemName,stateToSet);
      }
      
      override public function onClick() : void
      {
         if(state == STATE_BUBBLE_SMALL)
         {
            setState(STATE_BUBBLE_BIG);
         }
         else
         {
            setState(STATE_IDLE);
            UI.displayPopup(new BobBerryFarmWindow(this.m_dialogUrl,name));
         }
      }
      
      public function updateState() : void
      {
         var bobManager:BobBerryManager = BobBerryManager.getInstance(name);
         if(bobManager.shouldShowComeBackPopup())
         {
            setState(STATE_BUBBLE_SMALL);
         }
         else if(bobManager.shouldShowReward())
         {
            setState(STATE_HAPPY);
         }
         else
         {
            setState(STATE_IDLE);
         }
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         this.updateState();
      }
      
      override public function loadXmlData(xmlData:XML) : void
      {
         var dialogUrlXML:XMLList = xmlData.child("dialogUrl");
         this.m_dialogUrl = dialogUrlXML[0].toString();
      }
      
      override public function getCurrentImageName() : String
      {
         return state;
      }
   }
}


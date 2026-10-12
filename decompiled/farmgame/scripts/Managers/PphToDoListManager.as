package Managers
{
   import Classes.PphToDo.CloseToCropMasteryAction;
   import Classes.PphToDo.GetBushelsAction;
   import Classes.PphToDo.PphAction;
   import flash.utils.getDefinitionByName;
   
   public class PphToDoListManager
   {
      
      private static var m_allowInstantiation:Boolean;
      
      private static var m_instance:PphToDoListManager = null;
      
      private static const INVALID_INDEX:int = -1;
      
      private var m_actionsList:Array = [CloseToCropMasteryAction,GetBushelsAction];
      
      private var m_action:PphAction = null;
      
      private var m_actionType:String = null;
      
      public function PphToDoListManager()
      {
         super();
         if(!m_allowInstantiation)
         {
            throw new Error("Error: Instantiation failed: Use PphToDoListManager.getInstance() instead of new.");
         }
      }
      
      public static function getInstance() : PphToDoListManager
      {
         if(m_instance == null)
         {
            m_allowInstantiation = true;
            m_instance = new PphToDoListManager();
            m_allowInstantiation = false;
         }
         return m_instance;
      }
      
      public function init(startingActionType:String) : void
      {
         if(startingActionType != null)
         {
            this.m_actionType = startingActionType;
            this.m_action = this.getNextAction();
            if(this.m_action != null)
            {
               this.addHUDIcon();
            }
         }
      }
      
      public function doAction() : void
      {
         this.m_action.takeAction();
      }
      
      private function addHUDIcon() : void
      {
         this.m_action.getHudIcon();
      }
      
      private function getNextAction() : PphAction
      {
         var actionsListLength:int = 0;
         var nextIndex:int = 0;
         var actionIndex:int = 0;
         var result:PphAction = null;
         var actionClass:Class = null;
         var action:PphAction = null;
         var startIndex:int = this.pickStartIndex();
         if(startIndex != PphToDoListManager.INVALID_INDEX)
         {
            actionsListLength = int(this.m_actionsList.length);
            nextIndex = startIndex;
            for(actionIndex = 0; actionIndex < actionsListLength; actionIndex++)
            {
               actionClass = this.m_actionsList[nextIndex];
               action = new actionClass();
               if(action.createData() == true)
               {
                  result = action;
                  break;
               }
               nextIndex = (nextIndex + 1) % actionsListLength;
            }
         }
         return result;
      }
      
      private function pickStartIndex() : int
      {
         var className:String = null;
         var classType:Class = null;
         var index:int = int(PphToDoListManager.INVALID_INDEX);
         className = "Classes.PphToDo::" + this.m_actionType;
         try
         {
            classType = getDefinitionByName(className) as Class;
            index = this.m_actionsList.indexOf(classType);
         }
         catch(e:Error)
         {
            GlobalEngine.log("PphAction",className + " is not a defined PPH action");
         }
         return index;
      }
   }
}


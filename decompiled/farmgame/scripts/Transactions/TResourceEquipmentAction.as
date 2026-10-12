package Transactions
{
   import Classes.ResourceEquipment;
   import Engine.Helpers.Vector3;
   import Managers.FarmStatsManager;
   
   public class TResourceEquipmentAction extends TFarmTransaction
   {
      
      public static const METHOD_USE_EQUIPMENT:String = "onUseEquipment";
      
      public static const ACTION_HARVEST:String = "harvest";
      
      private static var m_numPending:Object = new Object();
      
      protected var m_action:String = "";
      
      protected var m_equipment:ResourceEquipment;
      
      protected var m_resourceBundle:Array;
      
      protected var m_equipmentBundle:Object;
      
      public function TResourceEquipmentAction(action:String, equipment:ResourceEquipment, resourceBundle:Array)
      {
         var aResourceBundle:Object = null;
         var id:Number = NaN;
         this.m_resourceBundle = [];
         this.m_equipmentBundle = {};
         super();
         this.m_action = action;
         this.m_equipment = equipment;
         for each(aResourceBundle in resourceBundle)
         {
            if(aResourceBundle.hasOwnProperty("position") && aResourceBundle["position"] is Vector3)
            {
               aResourceBundle["position"] = (aResourceBundle["position"] as Vector3).toObject();
            }
         }
         this.m_resourceBundle = resourceBundle;
         id = isNaN(equipment.getId()) ? -1 : equipment.getId();
         var potentialKey:String = equipment.getItem().code + ":" + equipment.equipmentPartsCount;
         this.m_equipmentBundle = {
            "id":id,
            "key":potentialKey
         };
         if(m_numPending[this.m_equipment.getItemName()])
         {
            ++m_numPending[this.m_equipment.getItemName()];
         }
         else
         {
            m_numPending[this.m_equipment.getItemName()] = 1;
         }
      }
      
      public static function getNumPending(itemName:String) : int
      {
         return m_numPending[itemName];
      }
      
      override public function perform() : void
      {
         signedCall("ResourceEquipmentWorldService." + METHOD_USE_EQUIPMENT,this.m_action,this.m_equipmentBundle,this.m_resourceBundle);
      }
      
      override protected function onComplete(result:Object) : void
      {
         if(m_numPending[this.m_equipment.getItemName()])
         {
            --m_numPending[this.m_equipment.getItemName()];
         }
         else
         {
            m_numPending[this.m_equipment.getItemName()] = 0;
         }
         if(Boolean(result) && result is Array)
         {
            this.m_equipment.onMultiActionComplete(this.getTransactionData(),result);
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = {};
         result.method = METHOD_USE_EQUIPMENT;
         result.action = this.m_action;
         result.equipmentItem = this.m_equipment.getItem();
         result.resourceBundle = this.m_resourceBundle;
         return result;
      }
      
      override protected function handleGoalResponse(result:Object) : void
      {
         var goal:Object = null;
         result.multiAction = true;
         super.handleGoalResponse(result);
         var masteryCount:int = 0;
         if(result.goals)
         {
            for each(goal in result.goals)
            {
               if(Boolean(goal) && goal["type"] == GOAL_TYPE_MASTERY)
               {
                  masteryCount++;
               }
            }
         }
         if(masteryCount > 0)
         {
            FarmStatsManager.count("use_equipment","mastery",this.m_equipment.getItemName(),String(masteryCount));
         }
      }
   }
}


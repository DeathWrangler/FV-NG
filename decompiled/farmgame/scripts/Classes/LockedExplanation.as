package Classes
{
   import Classes.LockedExplanations.LockedExplanationHandler;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import flash.utils.getDefinitionByName;
   
   public class LockedExplanation
   {
      
      private var m_prereqType:String;
      
      private var m_prereqValue:String;
      
      private var m_prereqs:Array;
      
      private var m_explanationDisplayVariants:XMLList;
      
      private var m_activeExplanationVariant:XML;
      
      public function LockedExplanation(prereqType:String, prereqValue:String, prereqs:Array, explanationDisplayVariants:XMLList)
      {
         super();
         this.m_prereqType = prereqType;
         this.m_prereqValue = prereqValue;
         this.m_prereqs = prereqs;
         this.m_explanationDisplayVariants = explanationDisplayVariants;
      }
      
      public static function fromXML(xml:XML) : LockedExplanation
      {
         var activeExplanationVariants:XMLList = null;
         var prereqType:String = xml.@prereqType;
         var prereqValue:String = xml.@prereqValue;
         var prereqs:Array = null;
         if(xml.hasOwnProperty("prereqs"))
         {
            prereqs = PrerequisiteUtility.parseXmlNodePrereqs(xml.prereqs);
         }
         if(xml.explanationVariants)
         {
            activeExplanationVariants = xml.explanationVariants.explanationVariant;
         }
         return new LockedExplanation(prereqType,prereqValue,prereqs,activeExplanationVariants);
      }
      
      public function get prereqType() : String
      {
         return this.m_prereqType;
      }
      
      public function get prereqValue() : String
      {
         return this.m_prereqValue;
      }
      
      public function showExplanation(lastQuantity:String = null) : void
      {
         var lockedClassName:String = null;
         var lockedHandlerClass:Class = null;
         var lockedHandler:LockedExplanationHandler = null;
         var paramObject:Object = null;
         var param:XML = null;
         this.getActiveExplanationDisplay();
         if(this.m_activeExplanationVariant)
         {
            if(this.m_activeExplanationVariant.hasOwnProperty("customHandler"))
            {
               lockedClassName = "Classes.LockedExplanations." + String(this.m_activeExplanationVariant.customHandler);
               lockedHandlerClass = getDefinitionByName(lockedClassName) as Class;
               lockedHandler = new lockedHandlerClass();
               paramObject = {};
               for each(param in this.m_activeExplanationVariant.customActionParams.children())
               {
                  paramObject[param.localName()] = param.toString();
               }
               paramObject["lastQuantity"] = lastQuantity;
               lockedHandler.execute(paramObject);
            }
            else if(this.m_activeExplanationVariant.genericPopup)
            {
               if(!(Boolean(this.m_activeExplanationVariant.genericPopup.@message_quantity) && Boolean(lastQuantity != null) && lastQuantity.length > 0))
               {
                  throw new Error("LockedExplanation::execute - message data is not defined for generic popup");
               }
               UI.displayPopup(new GenericPopup(ZLocUtils.t("Dialogs",this.m_activeExplanationVariant.genericPopup.@message_quantity,{"quantity":lastQuantity})),false);
            }
         }
      }
      
      public function getActiveExplanationDisplay() : void
      {
         var variant:XML = null;
         var variantPrereqs:Array = null;
         for each(variant in this.m_explanationDisplayVariants)
         {
            variantPrereqs = PrerequisiteUtility.parseXmlNodePrereqs(variant.prereqs);
            if(PrerequisiteUtility.arePrerequisitesMet(variantPrereqs))
            {
               this.m_activeExplanationVariant = variant;
               break;
            }
         }
      }
      
      public function isActive() : Boolean
      {
         var result:Boolean = false;
         if(this.m_prereqs == null)
         {
            result = true;
         }
         else if(this.m_prereqs.length > 0)
         {
            if(PrerequisiteUtility.arePrerequisitesMet(this.m_prereqs))
            {
               result = true;
            }
         }
         return result;
      }
   }
}


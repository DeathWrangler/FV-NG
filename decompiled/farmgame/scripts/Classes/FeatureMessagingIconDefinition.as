package Classes
{
   import Classes.Constants.PrerequisiteConstants;
   import Classes.Quest.PrerequisiteUtility;
   import Display.QueuedIcon;
   
   public class FeatureMessagingIconDefinition
   {
      
      private var m_type:String;
      
      private var m_prereqs:Array;
      
      private var m_image:String;
      
      private var m_tooltip:String;
      
      private var m_arrowTextKey:String;
      
      private var m_repeatableArrow:String;
      
      private var m_arrowFrequency:uint;
      
      private var m_hudSide:String;
      
      private var m_removeOnClick:Boolean;
      
      private var m_endDate:String = null;
      
      public function FeatureMessagingIconDefinition(xml:XMLList)
      {
         var arrowXml:XMLList = null;
         super();
         this.m_type = xml.hasOwnProperty("iconType") ? xml.iconType.toString() : QueuedIcon.ICON_TYPE_FEATURE_OF_THE_WEEK;
         if(xml.prereqs)
         {
            this.m_prereqs = PrerequisiteUtility.parseXmlNodePrereqs(xml.prereqs.children());
         }
         if(xml.image)
         {
            this.m_image = xml.image.toString();
         }
         if(xml.tooltip)
         {
            this.m_tooltip = xml.tooltip.toString();
         }
         if(xml.marketingArrow)
         {
            arrowXml = xml.marketingArrow;
            if(arrowXml.@repeatable)
            {
               this.m_repeatableArrow = arrowXml.@repeatable.toString();
            }
            if(arrowXml.arrowTextKey)
            {
               this.m_arrowTextKey = arrowXml.arrowTextKey.toString();
            }
            if(arrowXml.arrowFrequency)
            {
               this.m_arrowFrequency = arrowXml.arrowFrequency;
            }
         }
         if(xml.hudSide)
         {
            this.m_hudSide = xml.hudSide.toString();
         }
         if(xml.hasOwnProperty("removeOnClick"))
         {
            this.m_removeOnClick = parseInt(xml.removeOnClick.toString()) != 0;
         }
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      public function passesPrereqs() : Boolean
      {
         var prereq:Object = null;
         var result:Boolean = true;
         for each(prereq in this.m_prereqs)
         {
            if(!PrerequisiteUtility.isPrerequisiteMet(prereq))
            {
               result = false;
               break;
            }
            if(prereq[PrerequisiteConstants.KEY_TYPE] == PrerequisiteConstants.PREREQUISITE_END_TIME)
            {
               this.m_endDate = prereq[PrerequisiteConstants.KEY_VALUE];
            }
         }
         return result;
      }
      
      public function get image() : String
      {
         return this.m_image;
      }
      
      public function get tooltip() : String
      {
         return this.m_tooltip;
      }
      
      public function get endDate() : String
      {
         return this.m_endDate;
      }
      
      public function get arrowKey() : String
      {
         return this.m_arrowTextKey;
      }
      
      public function set arrowKey(key:String) : void
      {
         this.m_arrowTextKey = key;
      }
      
      public function get repeatableArrow() : String
      {
         return this.m_repeatableArrow;
      }
      
      public function get arrowFrequency() : uint
      {
         return this.m_arrowFrequency;
      }
      
      public function get hudSide() : String
      {
         return this.m_hudSide;
      }
      
      public function get removeOnClick() : Boolean
      {
         return this.m_removeOnClick;
      }
   }
}


package Classes
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   
   public class MarketMapping
   {
      
      private var m_inputPrereqs:Array = null;
      
      private var m_inputType:String = "";
      
      private var m_inputSubtype:String = "";
      
      private var m_inputSubsubtype:String = "";
      
      private var m_outputType:String = "";
      
      private var m_outputSubtype:String = "";
      
      private var m_outputSubsubtype:String = "";
      
      public function MarketMapping(xml:XML)
      {
         super();
         if(xml.input.attribute("type"))
         {
            this.m_inputType = xml.input.attribute("type");
         }
         if(xml.input.attribute("subtype"))
         {
            this.m_inputSubtype = xml.input.attribute("subtype");
         }
         if(xml.input.attribute("subsubtype"))
         {
            this.m_inputSubsubtype = xml.input.attribute("subsubtype");
         }
         if(xml.input.prereqs)
         {
            this.m_inputPrereqs = PrerequisiteUtility.parseXmlNodePrereqs(xml.input.prereqs.children());
         }
         if(xml.output.attribute("type"))
         {
            this.m_outputType = xml.output.attribute("type");
         }
         if(xml.input.attribute("subtype"))
         {
            this.m_outputSubtype = xml.output.attribute("subtype");
         }
         if(xml.input.attribute("subsubtype"))
         {
            this.m_outputSubsubtype = xml.output.attribute("subsubtype");
         }
      }
      
      public function matchesMapping(type:String, subtype:String = "", subsubtype:String = "", farmItem:FarmItem = null) : Boolean
      {
         var result:Boolean = false;
         if(type == this.m_inputType && (this.m_inputSubtype == "" || subtype == this.m_inputSubtype) && (this.m_inputSubsubtype == "" || subsubtype == this.m_inputSubsubtype) && PrerequisiteUtility.arePrerequisitesMet(this.m_inputPrereqs,farmItem))
         {
            result = true;
         }
         return result;
      }
      
      public function get outputType() : String
      {
         return this.m_outputType;
      }
      
      public function get outputSubtype() : String
      {
         return this.m_outputSubtype;
      }
      
      public function get outputSubsubtype() : String
      {
         return this.m_outputSubsubtype;
      }
   }
}


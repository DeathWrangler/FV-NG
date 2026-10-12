package Classes.Terrain
{
   public class Terrain
   {
      
      protected var m_code:int;
      
      protected var m_name:String;
      
      protected var m_numTypes:int;
      
      protected var m_probabilities:Vector.<Vector.<int>> = null;
      
      protected var m_pTotals:Vector.<int> = null;
      
      protected var m_wet:Boolean = false;
      
      protected var m_pathable:Boolean = true;
      
      protected var m_url:String = null;
      
      protected var m_icon:String = null;
      
      protected var m_height:Number;
      
      public function Terrain(xml:XML)
      {
         var typeWeights:Array = null;
         var numWeights:int = 0;
         var totalWeight:int = 0;
         var j:int = 0;
         var k:int = 0;
         var weightsXml:XML = null;
         var tmp:int = 0;
         super();
         if(xml.hasOwnProperty("weights"))
         {
            weightsXml = XML(xml.weights);
            if(weightsXml.hasOwnProperty("t24"))
            {
               this.m_numTypes = 25;
            }
            else if(weightsXml.hasOwnProperty("t12"))
            {
               this.m_numTypes = 13;
            }
            else
            {
               this.m_numTypes = 1;
            }
            this.m_probabilities = new Vector.<Vector.<int>>(this.m_numTypes);
            this.m_pTotals = new Vector.<int>(this.m_numTypes);
            for(j = 0; j < this.m_numTypes; j++)
            {
               typeWeights = String(weightsXml["t" + j.toString()]).split(",");
               this.m_probabilities[j] = new Vector.<int>(typeWeights.length);
               totalWeight = 0;
               for(k = 0; k < typeWeights.length; k++)
               {
                  tmp = int(typeWeights[k]);
                  this.m_probabilities[j][k] = tmp;
                  totalWeight += tmp;
               }
               this.m_pTotals[j] = totalWeight;
            }
            this.m_wet = xml.hasOwnProperty("wet") && String(xml.wet) == "true";
            this.m_pathable = !(xml.hasOwnProperty("pathable") && String(xml.pathable) == "false");
            this.m_url = String(xml.url);
            this.m_height = Number(xml.height);
            this.m_icon = String(xml.icon);
         }
         this.m_code = int(xml.@code);
         this.m_name = String(xml.@name);
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get code() : int
      {
         return this.m_code;
      }
      
      public function get numTypes() : int
      {
         return this.m_numTypes;
      }
      
      public function get probabilities() : Vector.<Vector.<int>>
      {
         return this.m_probabilities;
      }
      
      public function get pTotals() : Vector.<int>
      {
         return this.m_pTotals;
      }
      
      public function get url() : String
      {
         return this.m_url;
      }
      
      public function get icon() : String
      {
         return this.m_icon;
      }
      
      public function get height() : Number
      {
         return this.m_height;
      }
      
      public function get wet() : Boolean
      {
         return this.m_wet;
      }
      
      public function get pathable() : Boolean
      {
         return this.m_pathable;
      }
   }
}


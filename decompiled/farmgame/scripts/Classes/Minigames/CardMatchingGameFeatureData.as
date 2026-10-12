package Classes.Minigames
{
   import Classes.util.ParseXMLUtil;
   import flash.geom.Point;
   
   public class CardMatchingGameFeatureData extends BaseFeatureData
   {
      
      private static const TAG_TIMER:String = "timer";
      
      private static const TAG_BOARDSIZE:String = "boardsize";
      
      private static const ATTIB_BOARDSIZE_X:String = "@x";
      
      private static const ATTIB_BOARDSIZE_Y:String = "@y";
      
      private var m_maxGameTimeInSeconds:Number = NaN;
      
      private var m_boardsize:Point = null;
      
      public function CardMatchingGameFeatureData(xml:XML, parent:MinigameData)
      {
         super(xml,parent);
      }
      
      public function get maxGameTimeInSeconds() : Number
      {
         return this.m_maxGameTimeInSeconds;
      }
      
      public function get boardsize() : Point
      {
         return this.m_boardsize;
      }
      
      override protected function parseXML() : void
      {
         var x:Number = NaN;
         var y:Number = NaN;
         super.parseXML();
         if(m_rawXml)
         {
            this.m_maxGameTimeInSeconds = ParseXMLUtil.parseRequiredNumber(m_rawXml,TAG_TIMER);
            if(!m_rawXml.hasOwnProperty(TAG_BOARDSIZE))
            {
               throw new Error("Error: missing required " + TAG_BOARDSIZE + " tag for xml=" + m_rawXml);
            }
            x = ParseXMLUtil.parseRequiredNumber(m_rawXml[TAG_BOARDSIZE][0],ATTIB_BOARDSIZE_X);
            y = ParseXMLUtil.parseRequiredNumber(m_rawXml[TAG_BOARDSIZE][0],ATTIB_BOARDSIZE_Y);
            this.m_boardsize = new Point(x,y);
         }
      }
   }
}


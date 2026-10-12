package Classes
{
   public class TTNode
   {
      
      public var m_char:uint;
      
      public var m_left:TTNode;
      
      public var m_center:TTNode;
      
      public var m_right:TTNode;
      
      public var m_wordEnd:Array = null;
      
      public function TTNode(nodeChar:uint)
      {
         super();
         this.m_char = nodeChar;
      }
   }
}


module ExtendableSparseTest
using ExtendableSparse
using SparseArrays
using Printf



function randtest!(A::AbstractSparseMatrix{Tv,Ti},xnnz::Int,nsplice::Int) where {Tv,Ti}
    m,n=size(A)
    S=spzeros(m,n)
    for isplice=1:nsplice
        for inz=1:xnnz
            i=rand((1:m))
            j=rand((1:n))
            a=1.0+rand(Float64)
            S[i,j]+=a
            A[i,j]+=a
            @assert(nnz(S)==nnz(A))
        end
        flush!(A)
        for j=1:n
            @assert(issorted(A.cscmatrix.rowval[A.cscmatrix.colptr[j]:A.cscmatrix.colptr[j+1]-1]))
        end
        @assert(nnz(S)==nnz(A))

        (I,J,V)=findnz(S)
        for inz=1:nnz(S)
            @assert(A[I[inz],J[inz]]==V[inz])
        end

        (I,J,V)=findnz(A)
        for inz=1:nnz(A)
            @assert(S[I[inz],J[inz]]==V[inz])
        end

    end
    return true
end



function check(;m=1000,n=1000,nnz=5000,nsplice=1)
    mat=ExtendableSparseMatrix{Float64,Int64}(m,n)
    return randtest!(mat,nnz,nsplice)
end



function benchmark(;n=10000,m=10000,nnz=50000)
    
    println("SparseMatrixCSC:")
    mat=spzeros(Float64,Int64,m,n)
    @time sprand!(mat,nnz)
    
    println("SparseMatrixExtension:")
    extmat=SparseMatrixExtension{Float64,Int64}(m,n)
    @time sprand!(extmat,nnz)
    
    println("ExtendableSparseMatrix:")
    xextmat=ExtendableSparseMatrix{Float64,Int64}(m,n)
    @time begin
        sprand!(xextmat,nnz)
        @inbounds flush!(xextmat)
    end
    return
    b
end


end
